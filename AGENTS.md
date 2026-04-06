# AGENTS.md - dotfiles-wsl

WSL overlay dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy). Omarchy, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for inherited behavior and intentional differences. `dotfiles-arch` provides the shared Linux baseline used by this overlay.

## Scope

This repo is the additive WSL and Windows-specific overlay for the shared Linux baseline.

It owns:

- WSL-only additive Bash overlay in `bash-wsl/`
- WSL-only additive Neovim overlay in `nvim-wsl/`
- Windows Terminal configuration in `windows-terminal/`
- WSL-specific setup and overlay docs

It does not own:

- shared shell and terminal configs from `dotfiles-arch`
- shared Neovim options ownership from `dotfiles-arch/nvim/`

## Environment

- OS: WSL (Arch Linux)
- Terminal: Windows Terminal
- Dev: Tmux, Neovim (LazyVim), Bash

## Key Files

- `README.md` - overlay setup, stow order, and Windows Terminal application
- `DEVIATIONS.md` - intentional deviations from the shared baseline
- `.claude/skills/synchronize/SKILL.md` - repo-specific sync workflow for the overlay

## Setup Invariants

- WSL should consume `dotfiles-arch` first, then layer `bash-wsl/` and `nvim-wsl/` on top for WSL-only additions
- Complete the full `dotfiles-arch` setup before applying this overlay
- `~/.config/nvim` should already exist as a real LazyVim starter directory from the baseline setup
- `~/.config/bash-overlays/` is reserved for additive machine-specific shell behavior layered on top of the baseline
- `windows-terminal/settings.json` is a full paste-ready config applied manually from Windows, not stowed from WSL
- Git identity still comes from the baseline Git config via `~/.config/git/config.local`

## Reference Sources

- `/synchronize` expects the shared baseline locally at `~/projects/repos/dotfiles/dotfiles-arch`
- `/synchronize` expects local reference repos under the canonical `~/projects/repos/references/` root
- `~/projects/repos/references/omarchy` - main repo for bash, tmux, starship, git, fastfetch, btop, and editorconfig references
- `~/projects/repos/references/omarchy-pkgs` - package builds, including the Omarchy Neovim package
- `~/projects/repos/references/miasma.nvim` - Miasma color scheme source
- `~/projects/repos/references/windows-terminal` - Windows Terminal reference repo for settings structure and feature changes

## Skills

- `/synchronize` - sync this WSL overlay against `dotfiles-arch`, Omarchy references, and official WSL/Windows Terminal docs

## Workflow

- Use `/synchronize` when syncing this overlay against the baseline and upstream references
- Keep changes within the overlay scope of this repo
- Keep all intentional differences documented in `DEVIATIONS.md`
- Update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` together when ownership, setup, or sync assumptions change
- Put shared Linux behavior in `dotfiles-arch`, not here
