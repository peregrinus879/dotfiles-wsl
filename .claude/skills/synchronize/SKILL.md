---
name: synchronize
description: Sync this WSL repo against Omarchy references and official WSL and Windows Terminal docs. Covers all packages owned by dotfiles-wsl.
---

# Synchronize

Source configs from reference repos and official docs, compare against `dotfiles-wsl`, and apply changes only where they belong in this repo.

## Sources

### Reference Repos

Reference repos live under `~/Projects/repos/references/`:

- `omarchy/` - main repo for bash, tmux, starship, git, fastfetch, btop, and editorconfig references
- `omarchy-pkgs/` - package builds, including the Omarchy Neovim package
- `miasma.nvim/` - Miasma Neovim plugin source (the `OldJobobo/miasma.nvim` optimized fork used by Omarchy)
- `yazi/` - Yazi reference repo for configuration, theme, and feature changes
- `terminal/` - Windows Terminal reference repo for settings structure and feature changes

### Official Docs

- [The Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual) - setup guides, keybindings, workflows
- [WSL Docs](https://learn.microsoft.com/en-us/windows/wsl/) - installation, configuration, and interop
- [Install Arch Linux on WSL](https://wiki.archlinux.org/title/Install_Arch_Linux_on_WSL) - Arch Wiki guide
- [Windows Terminal Docs](https://learn.microsoft.com/en-us/windows/terminal/) - settings, profiles, color schemes, and keybindings
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html) - symlink management and package structure
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html) - builtins, expansion, scripting
- [Starship Configuration](https://starship.rs/config/) - module options and format strings
- [Tmux Wiki](https://github.com/tmux/tmux/wiki) - usage and recipes
- [LazyVim Docs](https://www.lazyvim.org/) - installation, extras, and plugin conventions
- [Neovim Docs](https://neovim.io/doc/) - options, API, and Lua reference
- [lazy.nvim Docs](https://lazy.folke.io/) - plugin manager configuration
- [Git Docs](https://git-scm.com/docs) - config options and behavior
- [Yazi Docs](https://yazi-rs.github.io/docs/) - configuration and themes
- [btop](https://github.com/aristocratos/btop) - config options and themes
- [fastfetch Wiki](https://github.com/fastfetch-cli/fastfetch/wiki) - modules and JSON config

## When To Use

- Use this skill when Omarchy or a reference repo changed materially.
- Use this skill when repo scope or behavior changed materially.
- Use this skill when you suspect undocumented drift between this repo and its references.
- Use this skill before broad sync-oriented doc updates.

## Workflow

1. Compare reference repos against the packages owned by `dotfiles-wsl`
2. For Omarchy-derived packages, compare against `omarchy/`, `omarchy-pkgs/`, and `miasma.nvim/`
3. For non-Omarchy tools such as Yazi, compare against `yazi/` and official docs
4. For Windows Terminal, compare `windows-terminal/settings.json` against `terminal/` and official docs
5. For each difference, classify it:
   - **Intentional deviation**: documented in `DEVIATIONS.md`, should stay different
   - **New upstream addition**: added upstream after the last sync, should be reviewed for inclusion
   - **Upstream change to existing config**: modified upstream, needs review
6. Check `git log --format="%h %ad %s" --date=short -- <file>` on the relevant reference repo when you need to determine when a difference was introduced
7. Cross-check differences against `DEVIATIONS.md`. If a difference is not documented there, treat it as a likely upstream change that needs review
8. Apply new upstream additions and changes where they belong in this repo
9. Update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` when package ownership, setup steps, or documented deviations change
10. Summarize which changes were adopted, rejected, or intentionally kept different

## Completion Checks

- `README.md`, `AGENTS.md`, and `DEVIATIONS.md` reflect any ownership, setup, or workflow changes
- Every retained difference is still documented in `DEVIATIONS.md`
- The final summary distinguishes adopted changes, rejected changes, and intentional retained differences

## Rules

- Present proposed changes to the user before editing
- Omarchy, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for default behavior and intentional differences
- Always check all relevant sources, not just one
- Never assume a difference is intentional without verifying it is documented in `DEVIATIONS.md`
- Keep the dual Miasma palette canons: terminal-side files track `themes/miasma/colors.toml` (`#78824b`), plugin-side files track `miasma.nvim` (`#78834b`)
- Keep shared AI harness runtime config in `dotfiles-ai`; this repo owns only WSL-specific OpenCode theme availability
- Do not add AUR packages or an AUR helper; the baseline depends on official Arch repos only
- Keep Windows-specific behavior explicit and documented
