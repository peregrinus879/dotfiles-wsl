---
name: update-docs
description: After code changes, verify and update dotfiles-wsl documentation (README.md, APPROACH.md) to stay in sync with configs and setup steps.
---

# Update Documentation

After making changes to dotfiles configs or setup, verify and update project documentation.

## Documentation Files

- `README.md` - Stack listing, stow packages, setup steps (0-10), clone/stow/unstow commands
- `APPROACH.md` - Methodology, Omarchy deviations with rationale, WSL-specific adaptations

## What to Verify

- Pacman package lists match what is actually needed (step 1 and step 4)
- Setup steps reference correct commands, flags, and file paths
- Stow package listing matches the actual top-level directories
- Stack listing matches the tools currently configured
- Tool install commands (LazyVim, Claude Code, OpenCode) are current
- Omarchy deviations in APPROACH.md reflect actual differences from upstream
- Removed configs are removed from docs; new configs are documented

## Rules

- Present proposed changes before editing
- Do not add, remove, or modify content beyond what the recent changes require
- Match existing formatting and style (headers, code blocks, bullet structure)
- Keep docs focused on user-facing setup and usage
