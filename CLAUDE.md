# dotfiles-wsl

WSL overlay dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy). Omarchy is the upstream reference, but `dotfiles-arch` is the baseline source of truth for shared Linux behavior.

## Scope

This repo is the WSL and Windows-specific overlay for the shared Linux baseline.

It owns:

- WSL-native Neovim overlay in `nvim-wsl/`
- Windows Terminal configuration in `windows-terminal/`
- WSL-specific setup and overlay docs

It does not own:

- shared shell and terminal configs from `dotfiles-arch`
- Arch-native Neovim overlay in `dotfiles-arch/nvim-arch/`

## Environment

- OS: WSL (Arch Linux)
- Terminal: Windows Terminal
- Dev: Tmux, Neovim (LazyVim), Bash

## Key Files

- `README.md` - overlay setup, stow order, and Windows Terminal application
- `APPROACH.md` - WSL-specific deviations from the shared baseline

## Stow Packages

Each top-level package is managed with GNU Stow and symlinked into `$HOME` where applicable.

- `nvim-wsl/`

Manual config:

- `windows-terminal/` - Windows Terminal `settings.json`, not stowed from WSL

WSL should consume `dotfiles-arch` first, and must not stow `nvim-arch/`.

## Reference Repos

Reference repos live under `~/projects/repos/references/`:

- `omarchy/` - main repo for bash, tmux, starship, git, fastfetch, btop, and editorconfig references
- `omarchy-pkgs/` - package builds, including the Omarchy Neovim package
- `miasma.nvim/` - Miasma color scheme source
- `windows-terminal/` - Windows Terminal reference repo for settings structure and feature changes

Related local repos:

- `~/projects/repos/dotfiles/dotfiles-arch` - shared Linux baseline this overlay depends on

## Skills

- `/synchronize` - sync this WSL overlay against `dotfiles-arch`, Omarchy references, and official WSL/Windows Terminal docs

## Workflow

- Use `/synchronize` when syncing this overlay against the baseline and upstream references
- Keep changes within the overlay scope of this repo
- Put shared Linux behavior in `dotfiles-arch`, not here
