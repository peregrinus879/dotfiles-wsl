# dotfiles-wsl

WSL (Arch Linux) dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy). Omarchy is the source of truth; deviate only when something breaks or does not apply on WSL.

## Key Files

- `README.md` - Stack, stow packages, setup steps
- `APPROACH.md` - Methodology and deviations from Omarchy

## Stow Packages

Each top-level directory (except `windows-terminal/`) is a GNU Stow package that symlinks into `$HOME`. Run `stow -v -t ~ <pkg>` from the repo root.

## Omarchy Reference

Omarchy repos are cloned as sibling directories:

- `../omarchy/` - Main repo (bash, tmux, starship, git, fastfetch, btop configs)
- `../omarchy-pkgs/` - Package builds (omarchy-nvim at `pkgbuilds/stable/omarchy-nvim/`)

## Skills

- `/ref-docs` - Official documentation links for all tools in the stack
- `/update-docs` - Update README.md and APPROACH.md after config changes
- `/sync-omarchy` - Source, compare, and update configs against Omarchy

## Workflow

1. Before changing configs, check official docs (`/ref-docs`)
2. When syncing with Omarchy updates, use `/sync-omarchy`
3. After any changes, update documentation (`/update-docs`)
