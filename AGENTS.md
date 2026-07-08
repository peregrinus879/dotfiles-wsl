# AGENTS.md - dotfiles-wsl

Self-contained WSL Arch dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy). Omarchy, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for default behavior and intentional differences.

## Scope

This repo carries the full terminal baseline for Arch Linux inside WSL, plus WSL and Windows-specific behavior.

It owns:

- GNU Stow packages for Bash, Git, Neovim, tmux, starship, fastfetch, btop, editorconfig, and Yazi
- the WSL-specific OpenCode Miasma theme in `opencode-wsl/`
- Windows Terminal configuration in `windows-terminal/`
- WSL setup and maintenance docs

It does not own:

- shared Claude Code and OpenCode runtime config from `dotfiles-ai`
- Omarchy desktop customizations from `dotfiles-omarchy`
- runbooks and hardware guides for the retiring headless host, which remain in the frozen `dotfiles-arch`

## Environment

- OS: WSL (Arch Linux)
- Terminal: Windows Terminal
- Dev: Tmux, Neovim (LazyVim), Bash

## Key Files

- `README.md` - package layout, setup, and verification
- `DEVIATIONS.md` - intentional deviations from Omarchy and boundary definitions
- `opencode-wsl/.config/opencode/themes/miasma.json` - OpenCode Miasma theme
- `.claude/skills/synchronize/SKILL.md` - repo-specific sync workflow against upstream references

## Setup Invariants

- `nvim/` assumes the LazyVim starter was cloned into `~/.config/nvim` first
- Bash may load additive machine-specific overlays from `~/.config/bash-overlays/` after the shared init; the directory is untracked and optional
- Git identity is expected in the untracked local file `~/.config/git/config.local`
- Nerd Font rendering comes from the Windows-installed font via Windows Terminal; WSL needs no Linux font package
- `~/.config/opencode/` and `~/.config/opencode/themes/` must be real merge directories so `dotfiles-ai` and `opencode-wsl` can both link files inside them
- `windows-terminal/settings.json` is a full paste-ready config applied manually from Windows, not stowed
- Baseline packages come from official Arch repos only; no AUR packages or AUR helper
- Windows interop stays enabled in `/etc/wsl.conf`; the Neovim clipboard integration requires `clip.exe` and `powershell.exe`

## Reference Sources

- `DEVIATIONS.md` for upstream GitHub URLs, the dual Miasma palette canons, and boundary definitions
- `.claude/skills/synchronize/SKILL.md` for local reference repo paths and official docs

## Skills

- `/synchronize` - sync this repo against Omarchy references and official WSL and Windows Terminal docs

## Workflow

- Use `/synchronize` when syncing against upstream references
- Keep changes within the scope of this repo
- Keep all intentional differences documented in `DEVIATIONS.md`
- Update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` together when ownership, setup, or sync assumptions change
- Keep shared AI harness runtime config in `dotfiles-ai`; use `opencode-wsl/` here only for WSL-specific OpenCode theme availability

## Future Enhancements

- **Makefile automation**: Wrap stow/unstow/dry-run, `make verify` for symlink and syntax checks, `make clean` for README "Prepare" cleanup steps. Combined stow order across repos: dotfiles-ai, dotfiles-wsl.
- **ShellCheck**: Makefile target or pre-commit hook covering `bash/.bashrc` and `bash/.config/bash/*`. `shellcheck` is already in the baseline package list. Known pre-existing SC2164/SC2155 warnings in upstream-derived functions are kept for Omarchy diffability.
- **Windows Terminal drift detection**: Script to checksum tracked `settings.json` against the deployed Windows-side file at `/mnt/c/Users/.../LocalState/settings.json`.

## Maintainer Checklist

1. Review the local reference repos and the current official WSL and Windows Terminal docs for upstream changes to owned packages.
2. Use `/synchronize` or compare manually against the upstream references.
3. Confirm every intentional difference is still documented in `DEVIATIONS.md`.
4. Update `README.md` when package ownership, setup steps, or verification steps change.
5. Confirm the setup invariants still hold: LazyVim starter, `~/.config/git/config.local`, package list, Stow targets, and OpenCode merge directories.
6. Keep `windows-terminal/settings.json` as a full paste-ready file unless the application model changes.
7. Start fresh WSL and Windows Terminal sessions after structural changes and verify the shell, Neovim, clipboard round-trip, and OpenCode theme still load cleanly.
