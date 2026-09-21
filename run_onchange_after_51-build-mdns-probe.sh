#!/usr/bin/env bash
#
# Build and install mdns-probe, a deadline-bounded hostname lookup used by
# ~/.ssh/config to prefer a host's .local name over its LAN and tailscale names.
#
# Kept out of 50-build-c-tools.sh because that script builds pinned upstream
# repos; this source has no upstream and lives in the heredoc below. chezmoi
# re-runs a `run_onchange_` script only when the script's own contents change,
# so editing the source below is exactly what triggers a rebuild.
#
# Why it exists: putting `local` in ssh's CanonicalDomains makes every lookup
# for a host that is not on the current link pay the resolver's full negative
# timeout, measured at 5.0s on both macOS (mDNSResponder) and Linux (avahi via
# nss-mdns). Bounding the query instead costs ~20ms on a hit and ~510ms on a
# miss at the default 500ms deadline.
#
# Portable: libc only, no Bonjour or avahi-compat headers, so the same source
# builds on the darwin laptops and the linux boxes. A host with no compiler is
# a normal case (minimal profile), and ssh treats a missing binary as a failed
# Match exec and falls through to CanonicalDomains, so skipping is safe.

set -euo pipefail

# Override to stage a build somewhere harmless when testing.
BINDIR="${CTOOLS_BINDIR:-${HOME}/.local/bin}"

note() { printf 'build-mdns-probe: %s\n' "$*"; }
warn() { printf 'build-mdns-probe: %s\n' "$*" >&2; }

if ! command -v cc > /dev/null 2>&1; then
  note "no cc on $(uname -n); skipping"
  exit 0
fi

mkdir -p "${BINDIR}"

build="$(mktemp -d)"
trap 'rm -rf "${build}"' EXIT

cat > "${build}/mdns-probe.c" << 'SOURCE'
/*
 * mdns-probe -- exit 0 if NAME resolves within a deadline.
 *
 * Used by ~/.ssh/config to prefer a host's .local name over its LAN and
 * tailscale names without paying the resolver's full negative-answer timeout
 * for a name that is not on the current link. That timeout is 5.0s on both
 * macOS (mDNSResponder) and Linux (avahi through nss-mdns), measured.
 *
 * getaddrinfo takes no timeout and cannot be cancelled safely, so the lookup
 * runs in forked children that report success down a shared pipe. The parent
 * waits on the pipe with select(2) and kills them at the deadline. EOF means
 * every child finished without resolving, which ends the wait early.
 *
 * One child per address family, because getaddrinfo only returns once it has
 * resolved A and AAAA both, and an unanswered family costs the full mDNS
 * timeout. Splitting them lets the first family to answer win. This is only a
 * presence test; ssh resolves the name itself once the config selects it.
 *
 * Deliberately resolver-agnostic rather than calling Bonjour or avahi directly:
 * one source builds on darwin and linux against libc alone, and .local is
 * reserved for mDNS by RFC 6762, so both systems route it to mDNS anyway.
 *
 * usage: mdns-probe [-t MILLISECONDS] NAME
 * exit:  0 resolved, 1 not resolved before the deadline, 2 usage error
 */

#include <errno.h>
#include <netdb.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char **argv) {
	/*
	 * Cold lookups are bimodal: 15, 19, 187 and 1231ms across four trials
	 * spaced past the 120s mDNS cache TTL, the outlier being a lost first
	 * multicast query that mDNS retries a second later. Warm lookups run
	 * 9-24ms. 500ms covers the fast mode with margin. Covering the retry
	 * would cost 1.5s on every host that is not on the link, to fix a
	 * fallthrough that is harmless -- ssh still connects via the LAN or
	 * tailscale name -- and self-correcting, because the late answer still
	 * lands in the resolver cache and the next lookup is warm.
	 */
	long ms = 500;
	int i = 1;

	if (argc > 2 && argv[1][0] == '-' && argv[1][1] == 't') {
		ms = strtol(argv[2], NULL, 10);
		i = 3;
	}
	if (i != argc - 1 || ms <= 0) {
		fprintf(stderr, "usage: mdns-probe [-t ms] name\n");
		return 2;
	}

	struct timeval start;
	gettimeofday(&start, NULL);

	int fd[2];
	if (pipe(fd) != 0)
		return 2;

	const int families[] = { AF_INET, AF_INET6 };
	const int nkids = (int)(sizeof families / sizeof families[0]);
	pid_t kids[sizeof families / sizeof families[0]];

	for (int k = 0; k < nkids; k++) {
		kids[k] = fork();
		if (kids[k] < 0)
			return 2;
		if (kids[k] == 0) {
			close(fd[0]);
			struct addrinfo hints, *res;
			memset(&hints, 0, sizeof hints);
			hints.ai_family = families[k];
			hints.ai_socktype = SOCK_STREAM;
			if (getaddrinfo(argv[i], NULL, &hints, &res) == 0 && res != NULL)
				if (write(fd[1], "1", 1) != 1)
					_exit(1);
			_exit(0);
		}
	}
	close(fd[1]);

	struct timeval deadline, now, tv;
	tv.tv_sec = ms / 1000;
	tv.tv_usec = (ms % 1000) * 1000;
	timeradd(&start, &tv, &deadline);

	int found = 0;
	for (;;) {
		gettimeofday(&now, NULL);
		if (timercmp(&now, &deadline, >=))
			break;
		timersub(&deadline, &now, &tv);
		fd_set rs;
		FD_ZERO(&rs);
		FD_SET(fd[0], &rs);
		int n = select(fd[0] + 1, &rs, NULL, NULL, &tv);
		if (n < 0) {
			if (errno == EINTR)
				continue;
			break;
		}
		if (n == 0)
			break;
		/* Readable: a byte means resolved, EOF means every child gave up. */
		char c;
		found = read(fd[0], &c, 1) == 1;
		break;
	}

	for (int k = 0; k < nkids; k++) {
		kill(kids[k], SIGKILL);
		waitpid(kids[k], NULL, 0);
	}
	close(fd[0]);

	if (getenv("MDNS_PROBE_VERBOSE")) {
		gettimeofday(&now, NULL);
		timersub(&now, &start, &tv);
		fprintf(stderr, "%s %s after %ldms\n", argv[i], found ? "found" : "MISS",
		        (long)(tv.tv_sec * 1000 + tv.tv_usec / 1000));
	}

	return found ? 0 : 1;
}
SOURCE

if ! cc -O2 -Wall -Wextra -o "${build}/mdns-probe" "${build}/mdns-probe.c"; then
  warn "build failed; keeping existing binary"
  exit 0
fi

install -m 755 "${build}/mdns-probe" "${BINDIR}/mdns-probe"
note "installed mdns-probe -> ${BINDIR}"

exit 0
