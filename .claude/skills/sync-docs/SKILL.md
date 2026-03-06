---
name: sync-docs
description: Cross-check and update README.md and APPROACH.md after any dotfile changes. Always run after modifying configs, adding tools, or changing deviations from Omarchy.
---

# Sync Documentation

After modifying any dotfiles, configs, or stack components, cross-check and update the following files to reflect the changes:

## Files to check

- `dotfiles-wsl/README.md` - Setup steps, package lists, stow package file listings, stack list
- `dotfiles-wsl/APPROACH.md` - Methodology, deviations from Omarchy, skipped components

## What to verify

1. **README.md**
   - Stack list matches current tools
   - Stow package file listings match actual directory contents
   - Setup steps reference correct packages and commands
   - Tool install commands are current

2. **APPROACH.md**
   - New deviations are documented with rationale
   - Removed deviations are deleted
   - Changed deviations are updated

## Rules

- Present proposed changes to the user before editing
- Do not add, remove, or modify content beyond what the recent changes require
- Match existing formatting and style conventions in each file
