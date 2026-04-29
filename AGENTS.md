# AGENTS.md - dotfiles-wsl

WSL overlay dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy). Omarchy, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for inherited behavior and intentional differences. `dotfiles-arch` provides the shared Linux baseline used by this overlay.

## Scope

This repo is the additive WSL and Windows-specific overlay for the shared Linux baseline.

It owns:

- WSL-only additive Bash overlay in `bash-wsl/`
- WSL-only additive Neovim overlay in `nvim-wsl/`
- WSL-only OpenCode Miasma theme in `opencode-wsl/`
- Windows Terminal configuration in `windows-terminal/`
- WSL-specific setup and overlay docs

It does not own:

- shared shell and terminal configs from `dotfiles-arch`
- shared Neovim options ownership from `dotfiles-arch/nvim/`
- shared OpenCode runtime config from `dotfiles-ai`

## Environment

- OS: WSL (Arch Linux)
- Terminal: Windows Terminal
- Dev: Tmux, Neovim (LazyVim), Bash

## Key Files

- `README.md` - overlay setup, stow order, and Windows Terminal application
- `DEVIATIONS.md` - intentional deviations from the shared baseline
- `opencode-wsl/.config/opencode/themes/miasma.json` - WSL OpenCode Miasma theme
- `.claude/skills/synchronize/SKILL.md` - repo-specific sync workflow for the overlay

## Setup Invariants

- WSL should consume `dotfiles-arch` first, then layer `bash-wsl/`, `nvim-wsl/`, and `opencode-wsl/` on top for WSL-only additions
- Complete the full `dotfiles-arch` setup before applying this overlay
- `~/.config/nvim` should already exist as a real LazyVim starter directory from the baseline setup
- `nvim-wsl/overlay.lua` is loaded automatically by `dotfiles-arch`'s `lua/config/options.lua` when present via `require("config.overlay").setup()`
- `~/.config/bash-overlays/` is reserved for additive machine-specific shell behavior layered on top of the baseline
- `opencode-wsl/` stows `~/.config/opencode/themes/miasma.json` so OpenCode can select Miasma in WSL without changing shared `dotfiles-ai` runtime config
- Use `stow --no-folding` for this overlay so the OpenCode theme file can coexist under `~/.config/opencode/`
- `windows-terminal/settings.json` is a full paste-ready config applied manually from Windows, not stowed from WSL
- Git identity still comes from the baseline Git config via `~/.config/git/config.local`

## Reference Sources

- `/synchronize` expects the shared baseline locally at `~/Projects/repos/dotfiles/dotfiles-arch`
- `/synchronize` expects local reference repos under the canonical `~/Projects/repos/references/` root
- `~/Projects/repos/references/omarchy` - main repo for bash, tmux, starship, git, fastfetch, btop, and editorconfig references
- `~/Projects/repos/references/omarchy-pkgs` - package builds, including the Omarchy Neovim package
- `~/Projects/repos/references/miasma.nvim` - Miasma color scheme source
- `~/Projects/repos/references/windows-terminal` - Windows Terminal reference repo for settings structure and feature changes

## Skills

- `/synchronize` - sync this WSL overlay against `dotfiles-arch`, Omarchy references, and official WSL/Windows Terminal docs

## Workflow

- Use `/synchronize` when syncing this overlay against the baseline and upstream references
- Keep changes within the overlay scope of this repo
- Keep all intentional differences documented in `DEVIATIONS.md`
- Update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` together when ownership, setup, or sync assumptions change
- Keep shared OpenCode runtime behavior in `dotfiles-ai`; use `opencode-wsl/` here only for WSL-specific OpenCode theme availability
- Put shared Linux behavior in `dotfiles-arch`, not here

## Maintainer Checklist

1. Review `dotfiles-arch` first and keep any shared Linux behavior there.
2. Review the current official WSL and Windows Terminal docs before changing setup or config structure.
3. Use `/synchronize` when comparing this overlay against the baseline and upstream references.
4. Confirm every intentional difference is still documented in `DEVIATIONS.md`.
5. Keep `windows-terminal/settings.json` as a full paste-ready file unless the application model changes.
6. Update `README.md` when setup order, verification steps, or Windows-side application steps change.
7. Confirm OpenCode still lists the stowed `miasma` theme from `~/.config/opencode/themes/miasma.json` before changing theme ownership.
8. Start fresh WSL and Windows Terminal sessions after structural changes and verify the overlay still applies cleanly.
