---
name: synchronize
description: Sync this WSL overlay against dotfiles-arch, upstream references, and official WSL and Windows Terminal docs.
---

# Synchronize Overlay

Source configs from `dotfiles-arch`, reference repos, and official docs, compare against `dotfiles-wsl`, and apply changes only where they belong in the WSL and Windows-specific overlay.

## Sources

### Local Baseline

- `~/projects/repos/dotfiles/dotfiles-arch` - shared Linux baseline that this overlay depends on

### Reference Repos

Reference repos live under `~/projects/repos/references/`:

- `omarchy/` - main repo for bash, tmux, starship, git, fastfetch, btop, and editorconfig references
- `omarchy-pkgs/` - package builds, including the Omarchy Neovim package
- `miasma.nvim/` - Miasma color scheme source
- `windows-terminal/` - Windows Terminal reference repo for settings structure and feature changes

### Official Docs

- [The Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual) - setup guides, keybindings, workflows
- [WSL Docs](https://learn.microsoft.com/en-us/windows/wsl/) - installation, configuration, and interop
- [Install Arch Linux on WSL](https://wiki.archlinux.org/title/Install_Arch_Linux_on_WSL) - Arch Wiki guide
- [Windows Terminal Docs](https://learn.microsoft.com/en-us/windows/terminal/) - settings, profiles, color schemes, and keybindings
- [LazyVim Docs](https://www.lazyvim.org/) - installation and plugin conventions
- [Neovim Docs](https://neovim.io/doc/) - options and Lua reference
- [lazy.nvim Docs](https://lazy.folke.io/) - plugin manager configuration
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html) - symlink management and package structure
- [Git Docs](https://git-scm.com/docs) - config options and behavior

## When To Use

- Use this skill when `dotfiles-arch` or a reference repo changed materially.
- Use this skill when overlay-owned behavior or ownership changed materially.
- Use this skill when you suspect undocumented drift between this repo, the baseline, and its references.
- Use this skill before broad sync-oriented doc updates.

## Workflow

1. Compare `dotfiles-wsl` against the WSL-relevant parts of `dotfiles-arch`
2. Compare overlay-owned files against relevant upstream references:
   - `bash-wsl/` against `dotfiles-arch` plus the documented personal repo auto-refresh deviation
   - `nvim-wsl/` against `omarchy-pkgs/` plus the WSL clipboard deviation
   - `windows-terminal/` against `windows-terminal/` and official docs
3. For each difference, classify it:
   - **Intentional deviation**: documented in `DEVIATIONS.md`, should stay different
   - **New upstream addition**: added after the last sync, should be reviewed for inclusion
   - **Upstream change to existing config**: modified upstream, needs review
4. Check `git log --format="%h %ad %s" --date=short -- <file>` on the relevant reference repo when you need to determine when a difference was introduced
5. Cross-check differences against `DEVIATIONS.md`. If a difference is not documented there, treat it as a likely upstream change that needs review
6. Apply new upstream additions and changes only where they belong in the WSL overlay
7. Update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` when overlay ownership, setup steps, or documented deviations change
8. Summarize which changes were adopted, rejected, or intentionally kept different

## Completion Checks

- `README.md`, `AGENTS.md`, and `DEVIATIONS.md` reflect any ownership, setup, or workflow changes
- Every retained difference is still documented in `DEVIATIONS.md`
- The final summary distinguishes adopted changes, rejected changes, and intentional retained differences

## Rules

- Present proposed changes to the user before editing
- Omarchy, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for inherited behavior and intentional differences
- `dotfiles-arch` provides the shared Linux baseline used by this overlay
- Always check all relevant sources, not just one
- Never assume a difference is intentional without verifying it is documented in `DEVIATIONS.md`
- Do not copy shared Linux behavior into this repo if it belongs in `dotfiles-arch`
- Keep the Neovim overlay additive: shared config stays in `dotfiles-arch/nvim/`, while `nvim-wsl/` only carries the WSL-specific overlay module
- Keep the Bash overlay additive: shared helpers stay in `dotfiles-arch`, while `bash-wsl/` only enables WSL-specific behavior
- Keep Windows-specific behavior explicit and confined to this overlay
