# AGENTS.md - EyrWSL

Self-contained Arch WSL dotfiles adapted from [Omarchy](https://github.com/omacom/omarchy) and managed with [GNU Stow](https://www.gnu.org/software/stow/). EyrWSL owns the terminal baseline plus WSL and Windows behavior. Omarchy's pinned baseline, official documentation, and `DEVIATIONS.md` define defaults, intentional differences, and ownership boundaries.

## Load Map

- Claude Code loads this file through the root `CLAUDE.md` `@AGENTS.md` import; skills load on invocation only.
- The `Makefile` is the single source of the package list (`scripts/verify.sh` and `scripts/prepare-stow.sh` consume it); `references.txt` lists the reference clones `/omasync` needs, and the family union of those files owns `~/Projects/quarry`; `README.md` carries the human-facing setup, verification, and maintenance detail; script headers own local constraints.
- `docs/maintenance.md` owns unresolved decisions, deferred work, active limitations, and dated revalidation evidence; read it before package, WSL, or Windows Terminal changes, `/omasync`, or deferred work. Prose describes current behavior; Git history owns provenance.

## Invariants

- Target machine: WSL2 with Windows interop enabled; run `stow`, `restow`, `clean`, `verify`, and `wt-push` only on the WSL host. `lint`, `check`, `twins`, and `refs` run anywhere.
- Because the packages are live configuration on the stowed host, an edit to a stowed file here is active for the next shell, Git command, Neovim session, or tmux server before any commit; work on this repository only in a session H is watching. `git/.config/git/config` is live for every Git command through its stow link and carries `[alias]` and `[include]`, so an alias or include edit is a code-execution change; it is diff-visible, which is why it stays inside the edit boundary rather than behind a deny.
- Stow runs with `--no-folding`, so every managed parent under `$HOME` is a real directory and only leaf files are links; generated host state therefore never reaches a package source. `make clean` removes only leftover folded links and dangling links whose text names a package entry this repository has, and aborts on a regular file at an owned path; `make verify` fails on a folded managed directory.
- When editing sibling dotfiles repos, use identical wording for shared concepts; only repo-specific values (scope, package lists, invariants) differ.
- The Makefile `TWIN_SPECS` files (nvim vault plugin specs, the `tdw` and `hdw` workspace functions, `yazi.toml`, `scripts/update-references.sh`, and `tests/update-references.sh`) are byte-identical twins with EyrArcHy; `make twins` (and `make verify` through it) fails on drift when the sibling clone is present and reports a skipped check when it is absent, and CI runs the same comparison against a fresh EyrArcHy clone.
- `make verify` must fail closed across WSL2/interoperability, commands, deployment ownership with real managed parents, Git identity (a GitHub no-reply address, never printed), and config parsing; fixture overrides must not weaken normal mode and never target the live home.
- Gruvbox is the only configured theme. Windows Terminal and btop use Omarchy's palette, Neovim uses Omarchy's `ellisonleao/gruvbox.nvim` selection, and ANSI-aware applications inherit the terminal palette.
- `nvim/` owns the complete LazyVim bootstrap, static configuration, and generated plugin lockfile; setup requires no separate config clone.
- Git identity lives in the untracked per-host `~/.config/git/config.local`; `make verify` asserts that it resolves to a GitHub no-reply address without printing it.
- Shared AI agent harness and OpenCode TUI configuration stay in EyrAgents, which deploys its own packages with `make stow` in its clone; nothing here touches `~/.config/opencode`, and EyrWSL carries no custom OpenCode theme.
- Packages come from official Arch repos; Claude Code and Herdr use canonical installers while official packages are unavailable. No AUR packages or helper.
- `windows-terminal/settings.json` is a full paste-ready config, never stowed; deploy it explicitly with `make wt-push`.
- Keep every intentional difference documented in `DEVIATIONS.md`; update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` together when ownership, setup, or sync assumptions change.

## Post-Change Verification

- Run `make lint` and `make check` after any change; CI runs both on every push to `main` and every pull request, and host-bound checks never run in CI.
- Run `make restow` and then `make verify` from the repo root on the WSL host after changing owned packages; deploying and verifying are the agent's steps (shared guidance), never left to H.
- Run `make wt-diff` before and after changing or deploying `windows-terminal/settings.json`.
- The full human checklist lives in `README.md` (Verify and Maintenance).

## Skills

- `/omasync` - sync this repo against Omarchy references and official WSL and Windows Terminal docs
