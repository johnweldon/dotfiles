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
- `Documents/PowerShell`

Everything else -- shell, git config and aliases, vim, ssh, and the `git-*-all` helper scripts -- installs in both profiles.

Note: the promoted `git-*-all` scripts and `bin/git_helpers.py` require `python3` on the target box.

## Notes

- chezmoi prefixes: `dot_` -> `.`, `private_` -> mode 0600, `executable_` -> +x, `readonly_` -> read-only. Files ending in `.tmpl` use Go templating.
- Template variables are defined in [`.chezmoi.toml.tmpl`](.chezmoi.toml.tmpl).

This repo supersedes the former `jw4/min.files` minimal-only repo, which is now archived. Use `profile = "minimal"` here instead.
