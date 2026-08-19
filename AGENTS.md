# AGENTS.md - EyrWSL

Self-contained WSL Arch dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy), managed with [GNU Stow](https://www.gnu.org/software/stow/): the full terminal baseline for Arch Linux inside WSL (Bash, Git, Neovim, tmux, Herdr, starship, fastfetch, btop, editorconfig, Yazi), plus WSL and Windows-specific behavior (the OpenCode Miasma theme in `opencode-wsl/`, Windows Terminal configuration in `windows-terminal/`). Omarchy tag `v4.0.0`, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for default behavior and intentional differences; ownership boundaries live in `DEVIATIONS.md` (Deviation Policy and Out Of Scope).

## Load Map

- Claude Code loads this file through the root `CLAUDE.md` `@AGENTS.md` import; skills load on invocation only.
- The `Makefile` is the single source of the package list; `README.md` carries the human-facing setup, verification, and maintenance detail.
- Repo-root `.claude/settings.json` and `opencode.json` are per-tool project allowlists for this repo's verification make targets (`verify`, `lint`).

## Invariants

- Target machine: WSL; run stow and make targets only on the WSL host.
- When editing sibling dotfiles repos, use identical wording for shared concepts; only repo-specific values (scope, package lists, invariants) differ.
- The Makefile `TWIN_SPECS` files (nvim vault plugin specs, the `tdw` and `hdw` workspace functions, `yazi.toml`) are byte-identical twins with EyrArcHy; `make verify` fails on drift.
- `nvim/` assumes the LazyVim starter was cloned into `~/.config/nvim` first.
- The vault is expected at `~/Projects/vault` (override with `OBSIDIAN_VAULT`) for the obsidian.nvim workflow.
- Git identity lives in the untracked per-host `~/.config/git/config.local`.
- `~/.config/opencode/` and `~/.config/opencode/themes/` must be real merge directories so EyrAgents and `opencode-wsl` can both link files inside them; shared AI agent harness runtime config stays in EyrAgents.
- Windows interop stays enabled in `/etc/wsl.conf`; the Neovim clipboard integration requires `clip.exe` and `powershell.exe`.
- Nerd Font rendering comes from the Windows-installed font via Windows Terminal; WSL needs no Linux font package.
- System packages, OpenCode, and Codex CLI come from official Arch repos; Claude Code and Herdr use canonical installers only while official packages are unavailable. No AUR packages or AUR helper.
- The README prerequisite list includes `inetutils` for `hostname`, `lua` for the fail-closed EyrWSL verifier, `nodejs` for EyrAgents verification, `tree-sitter-cli` for LazyVim, and `rsync`/`inotify-tools` for the adopted watcher.
- `windows-terminal/settings.json` is a full paste-ready config applied manually from Windows, not stowed.
- Bash may load additive machine-specific overlays from `~/.config/bash-overlays/` after the shared init; the directory is untracked and optional.
- Keep every intentional difference documented in `DEVIATIONS.md`; update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` together when ownership, setup, or sync assumptions change.
- Known Limitations records repo decisions and behavior official docs do not state; doc-derivable facts (defaults, version gates, upstream status) are fetched at change time, not cached here.

## Post-Change Verification

- Run `make verify` and `make lint` from the repo root after changing owned packages.
- Run `make wt-diff` before and after editing `windows-terminal/settings.json` so tracked and deployed stay in sync.
- Start fresh WSL and Windows Terminal sessions after structural changes and verify the shell, Neovim, clipboard round-trip, and OpenCode theme still load cleanly.
- The full human checklist lives in `README.md` (Verify and Maintenance).

## Known Limitations

- `:Obsidian paste_img` expects `wl-clipboard` or `xclip`, unavailable under WSL.
- Stow tree-folds directories that do not pre-exist at stow time (the README Prepare list) into directory symlinks pointing at the repo, so anything written there lands in the repo working tree; folding is the accepted repo-family stow convention (do not add `--no-folding`).

## Deferred Items

- watch the tree-folded `~/.config/yazi`: the first `ya pkg` install writes `plugins/` and `package.toml` into the repo working tree; decide then whether to track them (the EyrAgents opencode-deps pattern) or gitignore them (the git-identity pattern already guarded by this repo's `.gitignore`).
- mirror the sibling skill: EyrArcHy's skill is named `omasync` and includes reference-clone maintenance (re-resolve the upstream default branch with `git remote set-head origin -a`) and a cross-repo ledger coordination step; rename and adapt this repo's skill to match, keeping repo-specific content.
- finish the EyrAgents WSL host pass in fresh Claude Code, Codex, and OpenCode processes: verify `/commit` and `/spar`, and review app-managed trust rewrites before reconciliation.
- after this OpenCode session ends, remove only `~/.opencode/bin/opencode`, start a fresh shell, run `hash -r`, and verify `command -v opencode` resolves to Pacman's `/usr/bin/opencode`; keep the remaining `~/.opencode` content until separately audited.
- consider dropping the repo-root per-tool project allowlists (`.claude/settings.json`, `opencode.json`) as EyrArcHy did on 2026-08-15 (its commit cead290); verification approvals are handled session-side.

## Skills

- `/synchronize` - sync this repo against Omarchy references and official WSL and Windows Terminal docs
