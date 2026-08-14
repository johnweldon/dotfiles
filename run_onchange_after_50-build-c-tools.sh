#!/usr/bin/env bash
#
# Build and install the small C tools from source on this host.
#
# chezmoi re-runs a `run_onchange_` script only when the script's own contents
# change, so bumping a pinned revision below is exactly what triggers a rebuild.
# Editing a comment triggers one too -- that is the intended escape hatch.
#
# Why build instead of shipping binaries through chezmoi: these hosts are a mix
# of amd64 (workstations) and arm64 (the rpi4s), and the chezmoi source repo is
# public. Compiling per host keeps every architecture correct and keeps binaries
# out of git.
#
# Pinned revisions -- bump a SHA to pick up upstream changes:
#   cleanpath       jw4/tcleanpath              5dbcb02e  2025-06-18
#   jot             jw4/jot                     26332d8f  2024-04-12
#   list-git-repos  johnweldon/list-git-repos   e6694cb1  2026-08-14
#   statusline      johnweldon/statusline       44e41042  2026-06-06

set -euo pipefail

# Override BINDIR/CLAUDE_DIR to stage a build somewhere harmless when testing.
BINDIR="${CTOOLS_BINDIR:-${HOME}/.local/bin}"
CLAUDE_DIR="${CTOOLS_CLAUDE_DIR:-${HOME}/.claude}"
CACHE="${XDG_CACHE_HOME:-${HOME}/.cache}/chezmoi-c-tools"

# name | repo | pinned revision | make target
#
# The make target is spelled out for every tool because the default goal is not
# consistent upstream -- list-git-repos defaults to `help`, which would exit 0
# without building anything.
TOOLS="
cleanpath|https://github.com/jw4/tcleanpath.git|5dbcb02eecb55de8d18b4d72f44bd4c2f037a37b|cleanpath
jot|https://github.com/jw4/jot.git|26332d8fe354ae4431e1241734a8040265534314|jot
list-git-repos|https://github.com/johnweldon/list-git-repos.git|e6694cb179c9c1f6b92056e95cb873852e3741f6|list-git-repos
statusline|https://github.com/johnweldon/statusline.git|44e41042dc02891cfd0f2b313b77cd8ebfa3b44f|statusline
"

note() { printf 'build-c-tools: %s\n' "$*"; }
warn() { printf 'build-c-tools: %s\n' "$*" >&2; }

# A host without a toolchain is a normal case (minimal profile), not an error --
# leave whatever is already installed alone and say so.
for req in git make cc; do
  if ! command -v "${req}" >/dev/null 2>&1; then
    note "no ${req} on $(uname -n); skipping C tool builds"
    exit 0
  fi
done

mkdir -p "${BINDIR}" "${CACHE}"

failed=0

while IFS='|' read -r name repo rev target; do
  [ -n "${name}" ] || continue

  src="${CACHE}/${name}"

  if [ -d "${src}/.git" ]; then
    git -C "${src}" fetch --quiet origin || true
  else
    rm -rf "${src}"
    if ! git clone --quiet "${repo}" "${src}"; then
      warn "${name}: clone failed; keeping existing binary"
      failed=$((failed + 1))
      continue
    fi
  fi

  # Detached checkout at the pinned revision. Reachability is what matters, so a
  # plain fetch of the default branch is enough for a SHA that is on it.
  if ! git -C "${src}" checkout --quiet --detach "${rev}" 2>/dev/null; then
    warn "${name}: revision ${rev} not found; keeping existing binary"
    failed=$((failed + 1))
    continue
  fi

  # Clean first so switching revisions can never link stale object files.
  make -C "${src}" clean >/dev/null 2>&1 || true

  if ! make -C "${src}" "${target}" >/dev/null 2>&1; then
    warn "${name}: build failed; keeping existing binary"
    failed=$((failed + 1))
    continue
  fi

  case "${name}" in
    statusline)
      # Upstream owns this layout: the install target places the binary plus its
      # bashline/subagentline/antigravityline argv[0] symlinks. Use `install`
      # with an explicit PREFIX rather than `install-local`, which hardcodes
      # $(HOME)/.local/bin and would ignore BINDIR.
      make -C "${src}" install PREFIX="${BINDIR}" >/dev/null
      # Claude Code reads ~/.claude/statusline specifically, so mirror it there.
      if [ -d "${CLAUDE_DIR}" ]; then
        make -C "${src}" install-claude CLAUDE="${CLAUDE_DIR}" >/dev/null
      fi
      ;;
    *)
      install -m 755 "${src}/${target}" "${BINDIR}/${name}"
      ;;
  esac

  note "installed ${name} (${rev:0:8}) -> ${BINDIR}"
done <<EOF
${TOOLS}
EOF

if [ "${failed}" -gt 0 ]; then
  warn "${failed} tool(s) did not build; existing binaries were left in place"
fi

exit 0
