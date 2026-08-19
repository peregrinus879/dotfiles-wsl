# AGENTS.md - EyrWSL

Self-contained WSL Arch dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy), managed with [GNU Stow](https://www.gnu.org/software/stow/): the full terminal baseline for Arch Linux inside WSL (Bash, Git, Neovim, tmux, Herdr, starship, fastfetch, btop, editorconfig, Yazi), plus WSL and Windows-specific behavior in `windows-terminal/`. Omarchy tag `v4.0.0`, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for default behavior and intentional differences; ownership boundaries live in `DEVIATIONS.md` (Deviation Policy and Out Of Scope).

## Load Map

- Claude Code loads this file through the root `CLAUDE.md` `@AGENTS.md` import; skills load on invocation only.
- The `Makefile` is the single source of the package list; `scripts/verify.sh` consumes it through an environment argument, and `README.md` carries the human-facing setup, verification, and maintenance detail.
- `docs/maintenance.md` is the on-demand ledger for known limitations, deferred items, and dated findings; read it before package changes, WSL or Windows Terminal updates, `/omasync`, or work on a deferred item.

## Invariants

- Target machine: WSL; run stow and make targets only on the WSL host.
- When editing sibling dotfiles repos, use identical wording for shared concepts; only repo-specific values (scope, package lists, invariants) differ.
- `make verify` must fail closed across WSL2/interoperability, the command baseline, deployment ownership, resolved Git identity, owned config syntax and runtime parsing, and theme tombstones; fixture-only overrides must not weaken normal mode.
- Gruvbox is the only configured theme. Windows Terminal and btop track Omarchy's semantic palette, Neovim uses Omarchy's `ellisonleao/gruvbox.nvim` selection, and ANSI-aware applications inherit the terminal palette.
- `nvim/` owns the complete LazyVim bootstrap, static configuration, and generated plugin lockfile; setup requires no separate Neovim configuration clone.
- The vault is expected at `~/Projects/vault` (override with `OBSIDIAN_VAULT`) for the obsidian.nvim workflow.
- Git identity lives in the untracked per-host `~/.config/git/config.local`.
- Shared AI agent harness and OpenCode TUI configuration stay in EyrAgents; EyrWSL carries no custom OpenCode theme.
- Windows interop stays enabled in `/etc/wsl.conf`; the Neovim clipboard integration requires `clip.exe` and `powershell.exe`.
- Nerd Font rendering comes from the Windows-installed font via Windows Terminal; WSL needs no Linux font package.
- System packages, OpenCode, and Codex CLI come from official Arch repos; Claude Code and Herdr use canonical installers only while official packages are unavailable. No AUR packages or AUR helper.
- The README prerequisite list includes `inetutils` for `hostname`, `lua` for the fail-closed EyrWSL verifier, `nodejs` for EyrAgents verification, `tree-sitter-cli` for LazyVim, and `rsync`/`inotify-tools` for the adopted watcher.
- The fresh-host setup installs Arch directly with `wsl --install -d archlinux`, requires WSL2 and a root recovery password, and labels Yazi media helpers as optional rather than baseline.
- `windows-terminal/settings.json` is a full paste-ready config, never stowed; deployment is either manual or explicit through backup-first `make wt-push`.
- Bash may load additive machine-specific overlays from `~/.config/bash-overlays/` after the shared init; the directory is untracked and optional.
- Keep every intentional difference documented in `DEVIATIONS.md`; update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` together when ownership, setup, or sync assumptions change.

## Post-Change Verification

- Run `make verify` and `make lint` from the repo root after changing owned packages.
- Run `make wt-diff` before and after editing `windows-terminal/settings.json`; `make wt-push` validates both files and backs up the deployment before replacement.
- Start fresh WSL and Windows Terminal sessions after structural changes and verify the shell, Neovim, clipboard round-trip, and terminal-aware OpenCode theme still load cleanly.
- The full human checklist lives in `README.md` (Verify and Maintenance).

## Skills

- `/omasync` - sync this repo against Omarchy references and official WSL and Windows Terminal docs
