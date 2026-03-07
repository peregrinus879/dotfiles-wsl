# Approach

This document describes the methodology behind adapting [Omarchy](https://github.com/basecamp/omarchy) for WSL (Arch Linux) with Windows Terminal, and catalogues all deviations from the original.

## Methodology

Omarchy is an opinionated Arch Linux distribution targeting a full desktop environment (Hyprland, systemd units, GUI apps). This repo extracts only the terminal-layer configs and adapts them for a headless WSL environment with Windows Terminal.

**Guiding principles:**

- **Follow Omarchy conventions by default.** Aliases, keybindings, tmux layout ratios, and tool choices match Omarchy unless a WSL constraint forces a change.
- **Adapt only what breaks.** Changes are made when something does not work on WSL (e.g., no display server, no Ghostty, SSH agent not accessible from neovim's git subprocess).
- **Use GNU Stow for dotfile management.** Omarchy uses direct file copies and AUR packages. Stow provides symlink-based management suited to a personal dotfiles repo.
- **Single theme, no switching.** Omarchy supports 18 themes with hot-reloading. This repo uses Miasma exclusively, so theme switching infrastructure is omitted.
- **Avoid AUR.** All packages are installed from official Arch repos or via curl installers. This keeps the setup simple and reproducible.

**Source repos:**

- [basecamp/omarchy](https://github.com/basecamp/omarchy) - Main Omarchy repo (bash, tmux, starship, git, fastfetch, btop, editorconfig configs)
- [omacom-io/omarchy-pkgs](https://github.com/omacom-io/omarchy-pkgs) - Omarchy package builds (omarchy-nvim: LazyVim config, plugins, transparency, options)

## Deviations

### Terminal

- Windows Terminal replaces Ghostty. Miasma color scheme, JetBrainsMono Nerd Font, and padding settings are adapted from Ghostty's config into Windows Terminal's `settings.json`.

### Theme

- Only Miasma installed. Omarchy's `all-themes.lua` (15 lazy-loaded theme plugins) and `omarchy-theme-hotreload.lua` (hot-reload on LazyReload event) are skipped.

### Readability fixes

- **Tmux status bar**: `fg=#222222` instead of Omarchy's `fg=black`. Black text on olive green (`#78824b`) was unreadable on Windows Terminal.
- **Yazi theme**: Custom `theme.toml` with `fg=#222222` overrides for mode, status, and tab elements. Same readability issue.

### Bash

- Config location: `~/.config/bash/` (XDG pattern) instead of Omarchy's `~/.local/share/omarchy/default/bash/`.
- Modular functions in `~/.config/bash/functions/` sourced via loop in `.bashrc`. Omarchy sources individual files from `~/.local/share/omarchy/default/bash/fns/`.
- Dropped aliases: `open` (xdg-open, GUI-only), `d='docker'`, `r='rails'`.
- `cx` alias omits `--allow-dangerously-skip-permissions` flag present in Omarchy.
- Added `y()` function for Yazi cd-on-exit (Yazi is not part of Omarchy).
- Removed `mise` (runtime version manager) references. Not needed on WSL.

### Tmux dev layout

- Changed `tdl` split percentages from Omarchy's 85% editor / 30% AI / 15% terminal to 50% editor / 50% AI (top 85%) + terminal 15% (bottom). The bottom terminal pane matches Omarchy's 15%.

### Neovim

- WSL clipboard provider added in `options.lua`. Uses `clip.exe` for copy and `powershell.exe Get-Clipboard` for paste. Omarchy runs native Linux and does not need this.
- Skipped `all-themes.lua` and `omarchy-theme-hotreload.lua` (theme switching not needed).
- Added `lazyvim.plugins.extras.lang.markdown` extra. Not in Omarchy's omarchy-nvim.
- Kept verbatim from omarchy-nvim: `transparency.lua`, `disable-news-alert.lua`, `snacks-animated-scrolling-off.lua`, `vim.opt.relativenumber = false`.

### Fastfetch

- Rewritten for WSL. Kept the same box-drawing structure and section layout (Hardware / Software / Uptime).
- Dropped modules that do not exist on WSL: `display` (no monitor), `wm` (no window manager), `de` (no desktop environment), `wmtheme` (no WM theme).
- Dropped Omarchy-specific commands: `omarchy-version`, `omarchy-version-branch`, `omarchy-version-channel`, `omarchy-version-pkgs`, `omarchy-theme-current`.
- Dropped `OS Age` (uses `stat -c %W /` which may not work on WSL).
- Replaced Omarchy ASCII logo with fastfetch's built-in small logo.
- Replaced icon codepoints with Material Design Icons range for correct rendering in JetBrainsMono Nerd Font on Windows Terminal.
- Added `shell` and `os` modules (standard fastfetch modules not in Omarchy's config).

### Yazi

- Added entirely. Not part of Omarchy. Custom `yazi.toml` (ratio `[2, 4, 4]`, show hidden, dirs first) and Miasma `theme.toml`.

### Dotfile management

- GNU Stow with symlinks. Omarchy uses direct file copies, AUR packages, and the `omarchy-nvim-setup` script.

### Skipped from Omarchy

- All GUI/desktop components: Hyprland, Waybar, SDDM, Plymouth, SwayOSD, Mako, Walker, Fcitx5, hardware drivers, systemd desktop units, Elephant widgets.
- `omarchy-fish`, `omarchy-zsh`, `omarchy-walker` packages.
- `drives` functions (iso2sd, format-drive) - hardware-focused, not applicable to WSL.
- `transcoding` functions (video/image conversion) - GUI/hardware-focused, not applicable to WSL.
