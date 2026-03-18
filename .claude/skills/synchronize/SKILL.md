---
name: synchronize
description: Keep WSL configs aligned with Omarchy. Always source, compare, and update dotfiles when syncing with Omarchy changes.
---

# Sync with Omarchy

Source configs from the Omarchy repos, compare against dotfiles-wsl, and apply changes to keep WSL aligned.

## Omarchy Repos

These repos are cloned in the sibling `../upstream/` directory:

- `../upstream/omarchy/` - Main repo (bash, tmux, starship, git, fastfetch, btop configs)
- `../upstream/omarchy-pkgs/` - Package builds (omarchy-nvim at `pkgbuilds/stable/omarchy-nvim/`)

## Workflow

1. Pull latest changes from both Omarchy repos
2. Compare Omarchy configs against dotfiles-wsl equivalents
3. Identify new, changed, or removed configs
4. Apply changes to dotfiles-wsl, adapting for WSL where needed
5. Document any new deviations in `APPROACH.md` with rationale
6. Remove deviations from `APPROACH.md` that no longer apply

## Rules

- Present proposed changes to the user before editing
- Omarchy is the source of truth; deviate only when something breaks or does not apply on WSL
- Always check both repos, not just one
- Do not add WSL-specific changes that contradict Omarchy without documenting in APPROACH.md
