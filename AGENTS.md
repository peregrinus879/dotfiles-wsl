# AGENTS.md - EyrWSL

Self-contained Arch WSL dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy) and managed with [GNU Stow](https://www.gnu.org/software/stow/). EyrWSL owns the terminal baseline plus WSL and Windows behavior. Omarchy's pinned baseline, official documentation, and `DEVIATIONS.md` define defaults, intentional differences, and ownership boundaries.

## Load Map

- Claude Code loads this file through the root `CLAUDE.md` `@AGENTS.md` import; skills load on invocation only.
- The `Makefile` owns the package list, `scripts/verify.sh` consumes it, and `README.md` owns human-facing setup, verification, and maintenance detail.
- `docs/maintenance.md` is the on-demand ledger for known limitations, deferred items, and dated findings; read it before package, WSL, or Windows Terminal changes, `/omasync`, or deferred work.

## Invariants

- Target machine: WSL2 with Windows interop enabled; run Stow and Make targets only on the WSL host.
- When editing sibling dotfiles repos, use identical wording for shared concepts; only repo-specific values (scope, package lists, invariants) differ.
- `make verify` must fail closed across WSL2/interoperability, commands, deployment ownership, Git identity, and config parsing; fixture overrides must not weaken normal mode.
- Gruvbox is the only configured theme. Windows Terminal and btop use Omarchy's palette, Neovim uses Omarchy's `ellisonleao/gruvbox.nvim` selection, and ANSI-aware applications inherit the terminal palette.
- `nvim/` owns the complete LazyVim bootstrap, static configuration, and generated plugin lockfile; setup requires no separate config clone.
- Git identity lives in the untracked per-host `~/.config/git/config.local`.
- Shared AI agent harness and OpenCode TUI configuration stay in EyrAgents; EyrWSL carries no custom OpenCode theme.
- EyrAgents defaults to the sibling `../eyragents` clone; pass `EYRAGENTS_REPO` to both `make clean` and `make stow-all` when its clone lives elsewhere.
- Packages come from official Arch repos; Claude Code and Herdr use canonical installers while official packages are unavailable. No AUR packages or helper.
- `windows-terminal/settings.json` is a full paste-ready config, never stowed; deploy it explicitly with `make wt-push`.
- Keep every intentional difference documented in `DEVIATIONS.md`; update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` together when ownership, setup, or sync assumptions change.

## Post-Change Verification

- Run `make verify` and `make lint` from the repo root after changing owned packages.
- Run `make wt-diff` before and after changing or deploying `windows-terminal/settings.json`.
- The full human checklist lives in `README.md` (Verify and Maintenance).

## Skills

- `/omasync` - sync this repo against Omarchy references and official WSL and Windows Terminal docs
