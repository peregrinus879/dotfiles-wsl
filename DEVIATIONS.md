# Deviations

## Purpose

This document records the intentional differences carried by `dotfiles-wsl` relative to [Omarchy](https://github.com/basecamp/omarchy), and defines the boundary between this repo and its siblings.

Omarchy remains the upstream reference. This repo carries the full terminal baseline for Arch Linux inside WSL, plus the WSL and Windows-specific behavior that a Linux desktop distribution does not cover.

## Deviation Policy

Omarchy is an opinionated Arch Linux distribution targeting a full desktop environment with Hyprland, systemd user services, GUI applications, and hardware-specific integrations. This repo extracts the terminal-layer configuration that remains useful inside WSL and restructures it into GNU Stow packages.

**Guiding principles:**

1. **Follow Omarchy conventions by default.** Aliases, keybindings, tmux layout ratios, and tool choices should stay close to Omarchy unless a WSL or non-desktop constraint requires a change.
2. **Adapt only what breaks or does not apply.** Desktop-bound behavior, GUI launchers, and hardware workflows are omitted because they do not fit WSL.
3. **Keep Windows-specific behavior explicit.** Anything that depends on `clip.exe`, `powershell.exe`, or Windows Terminal should be documented as a Windows interop concern.
4. **Use GNU Stow for dotfile management.** Omarchy uses direct file copies and packaged assets. This repo uses symlink-based package ownership for clearer separation and reuse.
5. **Single theme, no switching.** Omarchy supports many themes and hot-reload infrastructure. This repo uses Miasma only, so theme switching infrastructure is intentionally omitted.
6. **Official Arch repos only.** The baseline depends on no AUR packages and installs no AUR helper.

## Reference Sources

- [basecamp/omarchy](https://github.com/basecamp/omarchy) - main repo for bash, tmux, starship, git, fastfetch, btop, and editorconfig references
- [omacom-io/omarchy-pkgs](https://github.com/omacom-io/omarchy-pkgs) - package builds, including the Omarchy Neovim package
- [OldJobobo/miasma.nvim](https://github.com/OldJobobo/miasma.nvim) - Miasma Neovim plugin used by Omarchy (optimized fork of `xero/miasma.nvim`)
- [microsoft/terminal](https://github.com/microsoft/terminal) - Windows Terminal settings structure and feature changes
- [sxyazi/yazi](https://github.com/sxyazi/yazi) and the [Yazi docs](https://yazi-rs.github.io/docs/) - file manager upstream and configuration reference
- [obsidian-nvim/obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim) - upstream for the vault plugin spec
- [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) - upstream for the markdown rendering spec
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
- [btop](https://github.com/aristocratos/btop) - config options and themes
- [fastfetch Wiki](https://github.com/fastfetch-cli/fastfetch/wiki) - modules and JSON config

The Miasma palette has two intentional canons in this repo. Terminal-side files (btop theme, Yazi theme, Windows Terminal scheme) track `themes/miasma/colors.toml` in `basecamp/omarchy`, which uses the `#78824b` olive accent, `#c2c2b0` as the terminal main fg, and intentionally identical ANSI bright and dark pairs (`color1..color7` equal `color9..color15`). Plugin-side files (the Neovim colorscheme and the OpenCode theme) track `miasma.nvim` with the slightly brighter `accent_primary = #78834b`. The tmux status bar uses upstream's ANSI palette names, resolved through the Windows Terminal scheme. Keep each file aligned with its own canon.

## Intentional Deviations

### Environment Target

- Arch Linux inside WSL, not a full Omarchy desktop.
- Desktop services, GUI launchers, display manager integration, and Hyprland-specific behavior are intentionally excluded.
- Nerd Font rendering is a Windows-side concern. Windows Terminal uses the Windows-installed JetBrainsMono Nerd Font; WSL needs no Linux font package.

### Dotfile Management

- GNU Stow with symlinked package ownership replaces Omarchy's file-copy and package-install model.

### Theme

- Only Miasma is configured. Omarchy's multi-theme plugin set and theme hot-reload infrastructure are omitted.

### Terminal

- Windows Terminal replaces Ghostty from the Omarchy desktop.
- Miasma colors, JetBrainsMono Nerd Font, and padding are adapted into `windows-terminal/settings.json`.
- The Miasma color scheme keeps the terminal-side canonical palette choices (Reference Sources) to stay consistent with Omarchy's terminal experience.

### Bash

- Config location is `~/.config/bash/` using an XDG-style layout instead of Omarchy's internal default path.
- Modular shell functions live in `~/.config/bash/functions/` and are sourced via a loop in `.bashrc`.
- Optional Bash overlays are sourced from `~/.config/bash-overlays/*` after the shared init. The directory is untracked and reserved for machine-local additions.
- Dropped aliases: `open` (GUI-only), `d='docker'`, and `r='rails'`.
- The kitty-conditional `ff` image-preview variant is omitted; Windows Terminal is not kitty, so the conditional would always take the plain `bat` branch kept here.
- `claude` is aliased to add `--effort ultracode`, so every interactive launch, including `cx` and `tdl`-launched AIs, inherits it via alias expansion; scripts and hooks stay plain. Ultracode is session-only upstream and cannot be set in `settings.json`.
- `cx` alias drops Omarchy's permission-bypass flag (currently `--permission-mode bypassPermissions` upstream).
- `cy` alias drops Omarchy's Codex sandbox-off and no-approval flags (currently `-s danger-full-access -a never` upstream), so no agent launcher skips permissions.
- `y()` is added for Yazi cd-on-exit support. Yazi is not part of Omarchy.
- `mise`-specific shell handling is omitted.
- No `pacman` alias and no AUR helper. Omarchy routes updates through `omarchy-update-perform`, which is Hyprland/desktop-bound; this repo uses plain `pacman` against official repos only.

### Git

- `~/.config/git/config` opens with `[include] path = ~/.config/git/config.local` so the local untracked `[user]` block is loaded first. Omarchy installs identity into the tracked file directly during install.
- `[init] defaultBranch = main` replaces Omarchy's `master`.
- Inline option comments are removed because the same intent is captured in this file. Omarchy keeps inline comments next to each option.
- Private Git identity is intentionally not tracked. WSL uses the untracked local file `~/.config/git/config.local` for `[user]` name and email.

### Starship

- The prompt shows `hostname` only during SSH sessions so remote shells are visually distinct from local ones while keeping the local prompt minimal.
- The `conflicted`, `up_to_date`, and `modified` Git status icons use Material Design Icons codepoints instead of Omarchy's Nerd Font private-use codepoints, matching the same broader-terminal-font compatibility rationale used for Fastfetch.

### Tmux

- Upstream's `M-Enter`, `M-S-Enter`, and `M-Escape` pane bindings are adopted verbatim; `alt+enter` is unbound in `windows-terminal/settings.json` (`"id": null`) because Windows Terminal's default binds it to fullscreen and would swallow `M-Enter` before it reaches tmux.
- The `?` keybindings-popup binding is omitted; it shells out to `omarchy-menu-tmux-keybindings`, which exists only on an Omarchy install.

### Tmux Dev Layout

- `tdl`, `tdlm`, and `tsl` track Omarchy's v3.8.4 `default/bash/fns/tmux` verbatim.

### Neovim

- `lua/config/options.lua` keeps Omarchy's `vim.opt.relativenumber = false` and `vim.g.autoformat = false` baseline and adds WSL clipboard integration directly, guarded by `clip.exe` and `powershell.exe` availability so the block is a no-op outside WSL. Copy uses `clip.exe`; paste uses `powershell.exe Get-Clipboard`.
- `all-themes.lua` and `omarchy-theme-hotreload.lua` are omitted because this repo uses Miasma only.
- Kept verbatim from `omarchy-nvim`: `disable-news-alert.lua`, `snacks-animated-scrolling-off.lua`, `vim.opt.relativenumber = false`, and `vim.g.autoformat = false`.
- `transparency.lua` content is verbatim from `omarchy-nvim` but relocated from `plugin/after/` to `after/plugin/` to use Neovim's actual after-load mechanism. Upstream `omarchy-nvim` still uses the incorrect path.
- Owned Lua files use 2-space indentation per the shared `.editorconfig` in this repo. Upstream `omarchy-nvim` uses tabs. Contents are otherwise unchanged.
- Two additive plugin specs are adopted from the vault's former `nvim-vault` package: `obsidian.lua` (obsidian.nvim against the vault at `~/Projects/vault`, override with `OBSIDIAN_VAULT`) and `render-markdown.lua` (visual markdown rendering companion). `python` joins the baseline package list because the vault keybindings shell out to the vault's `normalize.py`.
- The spec's `open.func` routes `obsidian://` and web URIs through Windows interop (`powershell.exe Start-Process`) when running under WSL, so `:Obsidian open` and link-following reach the Windows apps without `wsl-open`, which is not in official Arch repos. The override is guarded by `vim.fn.has("wsl")` and inert elsewhere; both repos track byte-identical copies of the spec.

### OpenCode

- `opencode-wsl/` stows `~/.config/opencode/themes/miasma.json` so OpenCode can select Miasma in WSL.
- The theme file is WSL-specific theme availability, not shared OpenCode runtime config. Runtime config remains owned by `dotfiles-ai`.
- `~/.config/opencode/` and `~/.config/opencode/themes/` stay real merge directories so `dotfiles-ai` and `opencode-wsl` can both link files inside them.
- The repo does not force OpenCode's selected theme. Select `miasma` with `/theme` so the choice remains a user-level OpenCode preference.
- `miasma.json` uses flat string values rather than the `{dark, light}` object pairs used by upstream OpenCode themes in `packages/ui/src/theme/themes/`. The flat form is valid against `https://opencode.ai/tui.json`. Miasma is dark-only upstream in `miasma.nvim`, so inventing a light variant would not be faithful to the canonical palette.
- Palette defs and role mappings track `miasma.nvim/lua/miasma/palette.lua` and the highlight definitions in `colors/miasma.vim`. Def names mirror the canonical palette (`base`, `surface`, `surfaceHighlight`, `text`, `textMuted`, `amber`, `orange`, `accentPrimary`, `accentSecondary`, `warning`, `error`). `primary` maps to `accentPrimary` (`#78834b`) so opencode's dominant accent matches miasma.nvim's Type, Function, and selection accent rather than the amber/string color. `syntaxString` maps to `warning` (`#685742`) per `M.string = M.warning` in palette.lua.

### Fastfetch

- Fastfetch is rewritten for a terminal-first environment instead of Omarchy's desktop-oriented presentation.
- The same box-drawing structure and section layout are kept: Hardware, Software, and Uptime.
- Desktop modules are omitted: `display`, `wm`, `de`, and `wmtheme`.
- Omarchy-specific helper commands are omitted: `omarchy-version`, `omarchy-version-branch`, `omarchy-version-channel`, `omarchy-version-pkgs`, and `omarchy-theme-current`.
- `OS Age` is omitted.
- Omarchy's ASCII logo is replaced with fastfetch's built-in small logo.
- Icon codepoints use the Material Design Icons range for broader terminal font compatibility.
- Standard modules `shell` and `os` are added.

### Btop

- `btop.conf` is based on the generated config format produced by current `btop`, including lowercase booleans and additional default settings.
- The intentional baseline change is `color_theme = "miasma"` instead of Omarchy's `"current"`.

### Yazi

- Added entirely. Yazi is not part of Omarchy.
- `yazi.toml` keeps the local layout and behavior choices: ratio `[2, 4, 4]`, hidden files shown, directories sorted first, `sort_by = "natural"`, and `linemode = "size"`.
- `theme.toml` carries the Miasma palette.
- One off-palette color, `#333333`, is kept for alternate and inactive backgrounds to create subtle separation from the base terminal background `#222222`.

### WSL Bootstrap

- `/etc/wsl.conf` carries the default user and keeps Windows interop enabled, which the clipboard integration requires.
- Windows-side installation of WSL, the Nerd Font, and Windows Terminal is documented in this repo's README.

## Skipped From Omarchy

- GUI and desktop components, including Hyprland, Waybar, SDDM, Plymouth, Mako, Walker, Fcitx5, and related user services
- SwayOSD, hardware drivers, Elephant widgets, and other desktop-bound integrations
- `omarchy-fish`, `omarchy-zsh`, and `omarchy-walker`
- `drives` functions such as `iso2sd` and `format-drive`
- `transcoding` functions for video and image conversion
- Hardware-focused tooling and desktop automation
- Theme switching infrastructure not needed for a single-theme setup
- Shell or app packages outside the chosen Bash plus terminal-tooling baseline

## Out Of Scope

The following do **not** belong in `dotfiles-wsl`:

- Shared OpenCode and Claude Code runtime config (belongs in `dotfiles-ai`)
- Omarchy desktop customizations such as Hyprland bindings (belong in `dotfiles-omarchy`)
