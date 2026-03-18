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
- `../upstream/miasma.nvim/` - Miasma color scheme source (palette, terminal exports in `extras/`)

## Workflow

1. Pull latest changes from all three repos
2. Compare Omarchy configs against dotfiles-wsl equivalents
3. For each difference, classify it:
   - **Intentional deviation**: Documented in `APPROACH.md`, should stay different
   - **New upstream addition**: Added in Omarchy after last sync, should be applied
   - **Upstream change to existing config**: Modified in Omarchy, needs review
4. Check `git log --format="%h %ad %s" --date=short -- <file>` on upstream repos to determine when differences were introduced
5. Cross-reference differences against `APPROACH.md` deviations. If a difference is NOT listed as a deviation, it is likely a new upstream change that should be synced
6. Apply new upstream additions and changes, adapting for WSL where needed
7. Document any new deviations in `APPROACH.md` with rationale
8. Remove deviations from `APPROACH.md` that no longer apply

## Rules

- Present proposed changes to the user before editing
- Omarchy is the source of truth; deviate only when something breaks or does not apply on WSL
- Always check all three repos, not just one
- Never assume a difference is intentional without verifying it is documented in `APPROACH.md`
- Do not add WSL-specific changes that contradict Omarchy without documenting in APPROACH.md
