# Deviations

## Purpose

This document records the intentional differences carried by `dotfiles-wsl` relative to the `dotfiles-arch` baseline, and defines the boundary between shared Linux behavior and WSL or Windows-specific overlay behavior.

Omarchy remains the upstream reference for the baseline design. `dotfiles-arch` provides the shared Linux baseline used by this overlay. This repo exists only to document and carry the additive overlay required for WSL with Windows Terminal and Windows interoperability.

## Deviation Policy

The baseline for shell, terminal tooling, theming, and shared Neovim behavior lives in `dotfiles-arch`.

This repo exists to keep WSL-specific behavior isolated and additive.

**Guiding principles:**

1. **Keep the overlay thin.** If a config works unchanged on headless Arch and WSL, it belongs in `dotfiles-arch`, not here.
2. **Adapt only what breaks or does not apply on WSL.** Windows interop, Windows Terminal, and clipboard integration belong here because they are not part of a portable Linux baseline.
3. **Keep the overlay additive.** If WSL only needs to extend a shared file, add a small overlay module instead of replacing baseline ownership.
4. **Keep Windows-specific behavior explicit.** Anything that depends on `clip.exe`, `powershell.exe`, or Windows Terminal should be documented as an overlay concern.

## Intentional Deviations

### Terminal

- Windows Terminal replaces Ghostty and any Linux-native terminal assumption from the baseline.
- Miasma colors, JetBrainsMono Nerd Font, and padding are adapted into `windows-terminal/settings.json`.
- Nerd Font installation remains a Windows-side concern. WSL does not need a separate Linux font package for icon rendering in Windows Terminal.

### OpenCode

- `.opencode/themes/miasma.json` provides a repo-local OpenCode Miasma theme for this WSL repo.
- The theme is project-local instead of global because shared OpenCode runtime config belongs to `dotfiles-ai`, and this repo only needs Miasma available when working in the WSL overlay.
- The repo does not force OpenCode's selected theme. Select `miasma` with `/theme` so the choice remains a user-level OpenCode preference.

### Bash

- `bash-wsl/` enables the shared repo auto-refresh helper from `dotfiles-arch` through an additive file in `~/.config/bash-overlays/`.
- This is a personal workflow deviation from Omarchy. It exists because the headless machine is the primary push source, while WSL benefits from automatic fetch plus fast-forward checks when entering repos under `~/Projects/repos`.
- The helper remains disabled by default in `dotfiles-arch` so the shared headless baseline does not auto-refresh repos unless an overlay opts in.

### Neovim

- `nvim-wsl/` provides `lua/config/overlay.lua`, which is loaded by the shared `dotfiles-arch` `lua/config/options.lua` when present.
- WSL clipboard integration is implemented with `clip.exe` for copy and `powershell.exe Get-Clipboard` for paste.
- This overlay stays additive so `dotfiles-arch` keeps ownership of the shared Neovim options file while WSL contributes only the Windows interoperability it needs.

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
- Shared OpenCode runtime config from `dotfiles-ai`
- Omarchy-derived baseline rationale that applies equally to headless Arch and WSL
