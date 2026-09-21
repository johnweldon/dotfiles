#!/usr/bin/env bash
#
# Build and install mdns-probe, a deadline-bounded multicast DNS lookup used by
# ~/.ssh/config to prefer a host's .local name over its LAN and tailscale names.
#
# Kept out of 50-build-c-tools.sh because that script builds pinned upstream
# repos; this source has no upstream and lives in the heredoc below. chezmoi
# re-runs a `run_onchange_` script only when the script's own contents change,
# so editing the source below is exactly what triggers a rebuild.
#
# Why it exists: putting `local` in ssh's CanonicalDomains makes every lookup
# for a host that is not on the current link pay mDNSResponder's full negative
# timeout, measured at 5.0s on macOS. Bounding the query instead costs ~18ms on
# a hit and ~265ms on a miss at the default 250ms deadline.
#
# Darwin only. The dns_sd API is in libSystem here and needs no linker flags; on
# Linux it would require avahi-compat-libdns_sd. ssh treats a missing binary as
# a failed Match exec and falls through to CanonicalDomains, so skipping is safe.

set -euo pipefail

# Override to stage a build somewhere harmless when testing.
BINDIR="${CTOOLS_BINDIR:-${HOME}/.local/bin}"

note() { printf 'build-mdns-probe: %s\n' "$*"; }
warn() { printf 'build-mdns-probe: %s\n' "$*" >&2; }

if [ "$(uname -s)" != Darwin ]; then
  note "not darwin; skipping (ssh falls back to CanonicalDomains)"
  exit 0
fi

if ! command -v cc > /dev/null 2>&1; then
  note "no cc on $(uname -n); skipping"
  exit 0
fi

mkdir -p "${BINDIR}"

build="$(mktemp -d)"
trap 'rm -rf "${build}"' EXIT

cat > "${build}/mdns-probe.c" << 'SOURCE'
/*
 * mdns-probe -- exit 0 if NAME answers on multicast DNS within a deadline.
 *
 * Used by ~/.ssh/config to prefer a host's .local name without paying
 * mDNSResponder's full negative-answer timeout (5s on macOS) for every
 * host that is not on the current link.
 *
 * usage: mdns-probe [-t MILLISECONDS] NAME
 * exit:  0 found, 1 not found before deadline, 2 usage or API error
 */

#include <dns_sd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/time.h>

static int found;

static void cb(DNSServiceRef ref, DNSServiceFlags flags, uint32_t ifindex,
               DNSServiceErrorType err, const char *host,
               const struct sockaddr *addr, uint32_t ttl, void *ctx) {
	(void)ref, (void)ifindex, (void)host, (void)ttl, (void)ctx;
	if (err == kDNSServiceErr_NoError && (flags & kDNSServiceFlagsAdd) &&
	    addr && (addr->sa_family == AF_INET || addr->sa_family == AF_INET6))
		found = 1;
}

int main(int argc, char **argv) {
	long ms = 250;
	int i = 1;

	if (argc > 2 && argv[1][0] == '-' && argv[1][1] == 't') {
		ms = strtol(argv[2], NULL, 10);
		i = 3;
	}
	if (i != argc - 1 || ms <= 0) {
		fprintf(stderr, "usage: mdns-probe [-t ms] name\n");
		return 2;
	}

	DNSServiceRef ref;
	if (DNSServiceGetAddrInfo(&ref, kDNSServiceFlagsForceMulticast,
	                          kDNSServiceInterfaceIndexAny,
	                          kDNSServiceProtocol_IPv4 | kDNSServiceProtocol_IPv6,
	                          argv[i], cb, NULL) != kDNSServiceErr_NoError)
		return 2;

	int fd = DNSServiceRefSockFD(ref);
	struct timeval deadline, now, tv;
	gettimeofday(&deadline, NULL);
	tv.tv_sec = ms / 1000;
	tv.tv_usec = (ms % 1000) * 1000;
	timeradd(&deadline, &tv, &deadline);

	while (!found) {
		gettimeofday(&now, NULL);
		if (timercmp(&now, &deadline, >=))
			break;
		timersub(&deadline, &now, &tv);
		fd_set rs;
		FD_ZERO(&rs);
		FD_SET(fd, &rs);
		int n = select(fd + 1, &rs, NULL, NULL, &tv);
		if (n < 0 && errno == EINTR)
			continue;
		if (n <= 0 || DNSServiceProcessResult(ref) != kDNSServiceErr_NoError)
			break;
	}

	DNSServiceRefDeallocate(ref);
	if (getenv("MDNS_PROBE_VERBOSE")) {
		struct timeval end;
		gettimeofday(&end, NULL);
		timersub(&deadline, &end, &tv);
		fprintf(stderr, "%s %s after %ldms\n", argv[i], found ? "found" : "MISS",
		        ms - (tv.tv_sec * 1000 + tv.tv_usec / 1000));
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
