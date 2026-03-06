---
name: ref-docs
description: Reference docs for the dotfiles stack. Always verify config syntax, defaults, and options against official sources before making changes.
---

# Documentation Reference

When working on dotfiles configs, fetch the relevant official documentation before making changes. Do not rely solely on training data.

## Omarchy

- [The Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual) - Setup guides, keybindings, workflows
- [basecamp/omarchy](https://github.com/basecamp/omarchy) - Main repo (bash, tmux, starship, git, fastfetch, btop configs)
- [omacom-io/omarchy-pkgs](https://github.com/omacom-io/omarchy-pkgs) - Package builds (omarchy-nvim at `pkgbuilds/stable/omarchy-nvim/`)

## WSL

- [WSL Docs](https://learn.microsoft.com/en-us/windows/wsl/) - Installation, configuration, networking
- [microsoft/WSL](https://github.com/microsoft/WSL) - GitHub repo
- [Install Arch Linux on WSL](https://wiki.archlinux.org/title/Install_Arch_Linux_on_WSL) - Arch Wiki guide

## Terminal

- [Windows Terminal Docs](https://learn.microsoft.com/en-us/windows/terminal/) - Settings, profiles, color schemes, keybindings
- [microsoft/terminal](https://github.com/microsoft/terminal) - GitHub repo

## Shell

- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html) - Builtins, expansion, scripting
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html) - Symlink management, package structure
- [aspiers/stow](https://github.com/aspiers/stow) - GitHub repo

## Prompt

- [Starship Configuration](https://starship.rs/config/) - Module options, format strings, presets
- [starship/starship](https://github.com/starship/starship) - GitHub repo

## Multiplexer

- [Tmux Wiki](https://github.com/tmux/tmux/wiki) - Getting started, FAQ, recipes
- [tmux/tmux](https://github.com/tmux/tmux) - GitHub repo

## Editor

- [LazyVim Docs](https://www.lazyvim.org/) - Installation, keymaps, plugins, extras
- [LazyVim/LazyVim](https://github.com/LazyVim/LazyVim) - GitHub repo
- [Neovim Docs](https://neovim.io/doc/) - Options, API, Lua reference
- [neovim/neovim](https://github.com/neovim/neovim) - GitHub repo
- [lazy.nvim Docs](https://lazy.folke.io/) - Plugin manager, spec format, lazy loading
- [folke/lazy.nvim](https://github.com/folke/lazy.nvim) - GitHub repo

## Version Control

- [Git Docs](https://git-scm.com/docs) - Reference, config options
- [git/git](https://github.com/git/git) - GitHub mirror
- [LazyGit](https://github.com/jesseduffield/lazygit) - Keybindings, custom commands, config

## File Manager

- [Yazi Docs](https://yazi-rs.github.io/docs/) - Configuration, keymaps, themes, plugins
- [sxyazi/yazi](https://github.com/sxyazi/yazi) - GitHub repo

## Monitoring

- [btop](https://github.com/aristocratos/btop) - Config options, themes, keybindings
- [fastfetch Wiki](https://github.com/fastfetch-cli/fastfetch/wiki) - Modules, JSON config schema
- [fastfetch-cli/fastfetch](https://github.com/fastfetch-cli/fastfetch) - GitHub repo

## AI

- [Claude Code Docs](https://code.claude.com/docs/en/overview) - Skills, memory, subagents, hooks
- [OpenCode Docs](https://opencode.ai/docs/) - Installation, configuration
- [opencode-ai/opencode](https://github.com/opencode-ai/opencode) - GitHub repo

## Utilities

- [charmbracelet/gum](https://github.com/charmbracelet/gum) - Interactive shell prompts

## Theme

- [xero/miasma.nvim](https://github.com/xero/miasma.nvim) - Neovim colorscheme, palette
- [Miasma colors.toml](https://github.com/basecamp/omarchy/blob/main/themes/miasma/colors.toml) - Omarchy color definitions

## Local References

- `~/projects/dotfiles/omarchy/` - Omarchy main repo
- `~/projects/dotfiles/omarchy-pkgs/` - Omarchy package builds
- `~/projects/dotfiles/dotfiles-wsl/APPROACH.md` - Methodology and deviations from Omarchy
