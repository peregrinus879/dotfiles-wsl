# Approach

This document describes the methodology behind the WSL-specific overlay carried by `dotfiles-wsl`.

`dotfiles-arch` is the shared Linux baseline. This repo documents only the deviations that are required because the environment is WSL with Windows Terminal.

## Methodology

The baseline for shell, terminal tooling, theming, and shared Neovim behavior lives in `dotfiles-arch`.

This repo exists to keep WSL-specific behavior isolated from that baseline.

**Guiding principles:**

- **Keep the overlay thin.** If a config works unchanged on headless Arch and WSL, it belongs in `dotfiles-arch`, not here.
- **Adapt only what breaks or does not apply on WSL.** Windows interop, Windows Terminal, and clipboard integration belong here because they are not part of a portable Linux baseline.
- **Avoid path collisions with the baseline.** WSL-specific Neovim behavior is isolated in `nvim-wsl/` so it can replace `nvim-arch/` cleanly.
- **Keep Windows-specific behavior explicit.** Anything that depends on `clip.exe`, `powershell.exe`, or Windows Terminal should be documented as an overlay concern.

## Deviations

### Terminal

- Windows Terminal replaces Ghostty and any Linux-native terminal assumption from the baseline.
- Miasma colors, JetBrainsMono Nerd Font, and padding are adapted into `windows-terminal/settings.json`.
- Nerd Font installation remains a Windows-side concern. WSL does not need a separate Linux font package for icon rendering in Windows Terminal.

### Neovim

- `nvim-wsl/` provides the WSL-specific `lua/config/options.lua`.
- WSL clipboard integration is implemented with `clip.exe` for copy and `powershell.exe Get-Clipboard` for paste.
- This overlay exists so WSL can avoid stowing `nvim-arch/` while still consuming the shared `nvim/` package from `dotfiles-arch`.

### Git Identity

- Private Git identity is intentionally not tracked in the shared dotfiles repos.
- WSL should use the untracked local file `~/.config/git/config.local` for `[user]` name and email.

### WSL Bootstrap

- `/etc/wsl.conf` remains a WSL concern because default user and Windows interop settings do not apply to native Arch.
- Windows-side installation of WSL and Windows Terminal is documented here, not in `dotfiles-arch`.

## Out Of Scope

The following do **not** belong in `dotfiles-wsl` because they are part of the shared baseline:

- Bash, tmux, starship, git, fastfetch, btop, editorconfig, and Yazi shared config
- Shared Neovim plugins and common LazyVim configuration
- Omarchy-derived baseline rationale that applies equally to headless Arch and WSL
