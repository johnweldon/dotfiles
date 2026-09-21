#!/usr/bin/env bash
#
# Build and install hostprobe, a deadline-bounded name-resolution and TCP
# reachability probe used by ~/.ssh/config.
#
# Kept out of 50-build-c-tools.sh because that script builds pinned upstream
# repos; this source has no upstream and lives in the heredoc below. chezmoi
# re-runs a `run_onchange_` script only when the script's own contents change,
# so editing the source below is exactly what triggers a rebuild.
#
# Two jobs, both of which have to be bounded:
#   - picking the mDNS tier in ssh canonicalization, where an absent .local
#     name otherwise costs the resolver's full 5.0s negative timeout
#   - deciding reachability for a route or a jump host, replacing `nc -z`,
#     whose connect timeout flag is -G on BSD and -w on GNU
#
# The second is why the ssh config is now identical text on every host.
#
# Portable: libc only, no Bonjour or avahi-compat headers, so the same source
# builds on the darwin laptops and the linux boxes. A host with no compiler is
# a normal case (minimal profile), and ssh treats a missing binary as a failed
# Match exec, falling back to CanonicalDomains and to direct routes, so
# skipping is safe.

set -euo pipefail

# Override to stage a build somewhere harmless when testing.
BINDIR="${CTOOLS_BINDIR:-${HOME}/.local/bin}"
# Honour an explicitly chosen compiler; cc is only the fallback.
CC="${CC:-cc}"

note() { printf 'build-hostprobe: %s\n' "$*"; }
warn() { printf 'build-hostprobe: %s\n' "$*" >&2; }

if ! command -v "${CC}" > /dev/null 2>&1; then
  note "no ${CC} on $(uname -n); skipping"
  exit 0
fi

mkdir -p "${BINDIR}"

build="$(mktemp -d)"
trap 'rm -rf "${build}"' EXIT

cat > "${build}/hostprobe.c" << 'SOURCE'
/*
 * hostprobe -- exit 0 if NAME resolves, or with -c, if it also accepts a TCP
 * connection on PORT, within a deadline.
 *
 * Used by ~/.ssh/config for two jobs that both have to be bounded:
 *
 *   hostprobe NAME.local        is NAME on this link? picks the mDNS tier
 *   hostprobe -c 22 NAME        is NAME reachable? picks a route or a jump
 *
 * The first exists because putting `local` in ssh's CanonicalDomains makes
 * every lookup for a host that is not on the current link pay the resolver's
 * full negative timeout, measured at 5.0s on both macOS (mDNSResponder) and
 * Linux (avahi via nss-mdns). The second replaces `nc -z`, whose connect
 * timeout flag is -G on BSD and -w on GNU; one spelling here means the ssh
 * config is identical text on every host, and 500ms instead of nc's 2s.
 *
 * getaddrinfo takes no timeout and cannot be cancelled safely, so the work
 * runs in forked children that report success down a shared pipe. The parent
 * waits on the pipe with select(2) and kills them at the deadline. EOF means
 * every child finished without success, which ends the wait early.
 *
 * One child per address family, because getaddrinfo only returns once it has
 * resolved A and AAAA both, and an unanswered family costs the full mDNS
 * timeout. Splitting them lets the first family to answer win.
 *
 * Deliberately resolver-agnostic rather than calling Bonjour or avahi
 * directly: one source builds on darwin and linux against libc alone, and
 * .local is reserved for mDNS by RFC 6762, so both systems route it to mDNS.
 *
 * usage: hostprobe [-t MILLISECONDS] [-c PORT] NAME
 * exit:  0 success, 1 no success before the deadline, 2 usage error
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
	const char *port = NULL;
	int i = 1;

	while (i + 1 < argc && argv[i][0] == '-' && argv[i][1] && !argv[i][2]) {
		if (argv[i][1] == 't')
			ms = strtol(argv[i + 1], NULL, 10);
		else if (argv[i][1] == 'c')
			port = argv[i + 1];
		else
			break;
		i += 2;
	}
	if (i != argc - 1 || ms <= 0) {
		fprintf(stderr, "usage: hostprobe [-t ms] [-c port] name\n");
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
			struct addrinfo hints, *res, *ai;
			memset(&hints, 0, sizeof hints);
			hints.ai_family = families[k];
			hints.ai_socktype = SOCK_STREAM;
			if (getaddrinfo(argv[i], port, &hints, &res) != 0 || res == NULL)
				_exit(0);
			/*
			 * Without -c, resolving is the whole question. With it, try
			 * each address and let the parent's deadline bound a connect
			 * that hangs; a blocking connect needs no timeout of its own.
			 */
			if (port != NULL) {
				for (ai = res; ai != NULL; ai = ai->ai_next) {
					int s = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
					if (s < 0)
						continue;
					int ok = connect(s, ai->ai_addr, ai->ai_addrlen) == 0;
					close(s);
					if (!ok)
						continue;
					if (write(fd[1], "1", 1) != 1)
						_exit(1);
					_exit(0);
				}
				_exit(0);
			}
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
		/* Readable: a byte means success, EOF means every child gave up. */
		char c;
		found = read(fd[0], &c, 1) == 1;
		break;
	}

	for (int k = 0; k < nkids; k++) {
		kill(kids[k], SIGKILL);
		waitpid(kids[k], NULL, 0);
	}
	close(fd[0]);

	if (getenv("HOSTPROBE_VERBOSE")) {
		gettimeofday(&now, NULL);
		timersub(&now, &start, &tv);
		fprintf(stderr, "%s%s%s %s after %ldms\n", argv[i], port ? ":" : "",
		        port ? port : "", found ? "ok" : "MISS",
		        (long)(tv.tv_sec * 1000 + tv.tv_usec / 1000));
	}

	return found ? 0 : 1;
}
SOURCE

if ! "${CC}" -O2 -Wall -Wextra -o "${build}/hostprobe" "${build}/hostprobe.c"; then
  warn "build failed; keeping existing binary"
  exit 0
fi

install -m 755 "${build}/hostprobe" "${BINDIR}/hostprobe"
note "installed hostprobe -> ${BINDIR}"

# Superseded by hostprobe, which does resolve-only with no -c flag.
if [ -e "${BINDIR}/mdns-probe" ]; then
  rm -f "${BINDIR}/mdns-probe"
  note "removed superseded mdns-probe"
fi

exit 0
