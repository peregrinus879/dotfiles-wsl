---
name: synchronize
description: Keep WSL configs current. Sync with Omarchy repos and verify against official docs. Covers all tools in the stack.
---

# Synchronize Configs

Source configs from Omarchy repos and official docs, compare against dotfiles-wsl, and apply changes.

## Sources

### Omarchy Repos

Cloned in the sibling `../upstream/` directory:

- `../upstream/omarchy/` - Main repo (bash, tmux, starship, git, fastfetch, btop configs)
- `../upstream/omarchy-pkgs/` - Package builds (omarchy-nvim at `pkgbuilds/stable/omarchy-nvim/`)
- `../upstream/miasma.nvim/` - Miasma color scheme source (palette, terminal exports in `extras/`)

### Official Docs

- [The Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual) - Setup guides, keybindings, workflows
- [WSL Docs](https://learn.microsoft.com/en-us/windows/wsl/) - Installation, configuration, networking
- [Install Arch Linux on WSL](https://wiki.archlinux.org/title/Install_Arch_Linux_on_WSL) - Arch Wiki guide
- [Windows Terminal Docs](https://learn.microsoft.com/en-us/windows/terminal/) - Settings, profiles, color schemes, keybindings
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html) - Builtins, expansion, scripting
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html) - Symlink management, package structure
- [Starship Configuration](https://starship.rs/config/) - Module options, format strings, presets
- [Tmux Wiki](https://github.com/tmux/tmux/wiki) - Getting started, FAQ, recipes
- [LazyVim Docs](https://www.lazyvim.org/) - Installation, keymaps, plugins, extras
- [Neovim Docs](https://neovim.io/doc/) - Options, API, Lua reference
- [lazy.nvim Docs](https://lazy.folke.io/) - Plugin manager, spec format, lazy loading
- [Git Docs](https://git-scm.com/docs) - Reference, config options
- [LazyGit](https://github.com/jesseduffield/lazygit) - Keybindings, custom commands, config
- [Yazi Docs](https://yazi-rs.github.io/docs/) - Configuration, keymaps, themes, plugins
- [btop](https://github.com/aristocratos/btop) - Config options, themes, keybindings
- [fastfetch Wiki](https://github.com/fastfetch-cli/fastfetch/wiki) - Modules, JSON config schema
- [Claude Code Docs](https://code.claude.com/docs/en/overview) - Skills, memory, subagents, hooks
- [OpenCode Docs](https://opencode.ai/docs/) - Installation, configuration

## Workflow

1. Pull latest changes from all three Omarchy repos
2. Compare Omarchy configs against dotfiles-wsl equivalents
3. For non-Omarchy tools (yazi, Windows Terminal), check official docs for changes
4. For each difference, classify it:
   - **Intentional deviation**: Documented in `APPROACH.md`, should stay different
   - **New upstream addition**: Added in Omarchy after last sync, should be applied
   - **Upstream change to existing config**: Modified in Omarchy, needs review
5. Check `git log --format="%h %ad %s" --date=short -- <file>` on upstream repos to determine when differences were introduced
6. Cross-reference differences against `APPROACH.md` deviations. If a difference is NOT listed as a deviation, it is likely a new upstream change that should be synced
7. Apply new upstream additions and changes, adapting for WSL where needed
8. Document any new deviations in `APPROACH.md` with rationale
9. Remove deviations from `APPROACH.md` that no longer apply

## Rules

- Present proposed changes to the user before editing
- Omarchy is the source of truth; deviate only when something breaks or does not apply on WSL
- Always check all three repos, not just one
- Never assume a difference is intentional without verifying it is documented in `APPROACH.md`
- Do not add WSL-specific changes that contradict Omarchy without documenting in APPROACH.md
