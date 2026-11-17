# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

A single `profile` setting selects how much gets installed:

- `full` (default): the complete environment -- Neovim/LazyVim, Homebrew Brewfile, VNC, all `bin/` helpers, and every config.
- `minimal`: a lean set for transient or freshly-provisioned boxes -- shell, git, vim, ssh, and the lightweight `bin/` git helpers, with the heavy/desktop pieces excluded.

The profile is selected at `chezmoi init` and persisted in `~/.config/chezmoi/chezmoi.toml`. It drives a templated [`.chezmoiignore`](.chezmoiignore) that excludes the full-only paths when `profile = "minimal"`. Selection order: the `DOTFILES_PROFILE` environment variable wins if set; otherwise you are prompted (default `full`).

## Install

### Full (workstation, default)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply johnweldon/dotfiles
```

`DOTFILES_PROFILE` is unset and the profile prompt defaults to `full`, so a non-interactive run installs the full set.

### Minimal (transient / newly-provisioned box)

Set `DOTFILES_PROFILE=minimal` for the install. You are prompted for identity (name, email, GitHub id, timezone); answer them or accept the timezone default:

```bash
DOTFILES_PROFILE=minimal sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply \
  https://github.com/johnweldon/dotfiles.git
```

For an ephemeral box where you do not want chezmoi or the source tree left behind, use `--one-shot` (applies once, then removes chezmoi and its source state):

```bash
DOTFILES_PROFILE=minimal sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot \
  https://github.com/johnweldon/dotfiles.git
```

The `DOTFILES_PROFILE` env var is the reliable way to preselect the profile; it bypasses the prompt entirely and is not affected by `--promptDefaults`. (Passing the profile via `--promptString` is fragile: it must be keyed by the exact prompt text, and `--promptDefaults` would override it back to `full`.)

### Unattended (cloud-init, no terminal)

Add `--promptDefaults` to run with no prompts at all. The identity prompts (name, email, GitHub id, timezone) fall back to their built-in defaults:

```bash
DOTFILES_PROFILE=minimal sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply \
  --promptDefaults https://github.com/johnweldon/dotfiles.git
```

This is the form to drop into a cloud-init `runcmd` / user-data script. Use `--one-shot` instead of `--apply` for an ephemeral box. `DOTFILES_PROFILE` selects the profile (omit it for full); `--promptDefaults` supplies the identity defaults so init never blocks on input.

## Switching an existing install

`DOTFILES_PROFILE` always wins, so re-run init with it set, then apply:

```bash
DOTFILES_PROFILE=minimal chezmoi init
chezmoi apply
```

To go back to full, run `DOTFILES_PROFILE=full chezmoi init` then `chezmoi apply`.

## What minimal excludes

When `profile = "minimal"`, the following are not deployed (see [`.chezmoiignore`](.chezmoiignore)):

- `bin/brew-upgrade`, `bin/pdftostdout`
- `build/data/Brewfile`
- `.astylerc`
- `.config/nvim` (Neovim/LazyVim), `.config/markdownlint-cli2.yaml`
- `.vnc`
- the Linux package check (`52-check-packages.sh`)
- `Documents/PowerShell`
- the Linux desktop login apps (see [Linux desktop login apps](#linux-desktop-login-apps))

Everything else -- shell, git config and aliases, vim, ssh, and the `git-*-all` helper scripts -- installs in both profiles.

Note: the promoted `git-*-all` scripts and `bin/git_helpers.py` require `python3` on the target box.

## Linux desktop login apps

On a full-profile Linux desktop running GNOME (or any desktop that honours XDG autostart), these open at login:

- Slack
- one Chrome window per listed profile, 3 seconds apart
- a kitty window running `ssh <ssh_host>`, attached to tmux session `<ssh_tmux_session>` when that is set, falling back to a local shell if ssh exits or the network is not up yet, plus a second kitty window with a local shell in `~`

The login session's `SSH_AUTH_SOCK` also points at the systemd user ssh-agent (`ssh-agent.socket`), so GUI apps share the agent your shells use.

They deploy only on hosts whose private `~/.config/chezmoi/chezmoi.toml` has a `[data.desktop]` table. Host and profile names live there rather than in this public repo. Every other host, including macOS and the minimal profile, ignores `.config/autostart`, `.config/environment.d` and `.config/kitty` entirely.

To enable it on a desktop, add the table under `[data]` and apply:

```toml
  [data.desktop]
    # Host for the first kitty window; empty opens only the local shell.
    ssh_host = "myhost"
    # Optional: tmux session on ssh_host to reattach at every login.
    ssh_tmux_session = "main"
    # Chrome profile directories, as named under ~/.config/google-chrome.
    chrome_profiles = ["Default", "Profile 1"]
```

```bash
chezmoi apply
```

Then make Chrome reopen your tabs. The autostart entry only opens a window per profile; what that window shows is a Chrome setting that chezmoi cannot write, because Chrome rejects outside edits to it. In each profile, open `chrome://settings/onStartup` and choose "Continue where you left off".

To list your profile directories and the names Chrome shows for them:

```bash
jq -r '.profile.info_cache | to_entries[] | "\(.key)\t\(.value.name)"' ~/.config/google-chrome/"Local State"
```

The entries expect `/usr/bin/slack`, `/usr/bin/google-chrome` and kitty at `~/.local/kitty.app/bin/kitty`. An entry whose program is missing is skipped. To try the kitty windows without logging out, run `gtk-launch kitty-desktop`. To stop one app opening, delete its file from `~/.config/autostart`; it comes back on the next `chezmoi apply` unless you also remove it from the repo.

## Notes

- chezmoi prefixes: `dot_` -> `.`, `private_` -> mode 0600, `executable_` -> +x, `readonly_` -> read-only. Files ending in `.tmpl` use Go templating.
- Template variables are defined in [`.chezmoi.toml.tmpl`](.chezmoi.toml.tmpl).

This repo supersedes the former `jw4/min.files` minimal-only repo, which is now archived. Use `profile = "minimal"` here instead.
