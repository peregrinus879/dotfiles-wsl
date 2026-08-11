# AGENTS.md - dotfiles-wsl

Self-contained WSL Arch dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy), managed with [GNU Stow](https://www.gnu.org/software/stow/): the full terminal baseline for Arch Linux inside WSL (Bash, Git, Neovim, tmux, starship, fastfetch, btop, editorconfig, Yazi), plus WSL and Windows-specific behavior (the OpenCode Miasma theme in `opencode-wsl/`, Windows Terminal configuration in `windows-terminal/`). Omarchy, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for default behavior and intentional differences; ownership boundaries live in `DEVIATIONS.md` (Deviation Policy and Out Of Scope).

## Load Map

- Claude Code loads this file through the root `CLAUDE.md` `@AGENTS.md` import; skills load on invocation only.
- The `Makefile` is the single source of the package list; `README.md` carries the human-facing setup, verification, and maintenance detail.
- Repo-root `.claude/settings.json` and `opencode.json` are per-tool project allowlists for this repo's verification make targets (`verify`, `lint`).

## Invariants

- Target machine: WSL; run stow and make targets only on the WSL host.
- When editing sibling dotfiles repos, use identical wording for shared concepts; only repo-specific values (scope, package lists, invariants) differ.
- The Makefile `TWIN_SPECS` files (nvim vault plugin specs, the `dw` workspace function, `yazi.toml`) are byte-identical twins with `dotfiles-omarchy`; `make verify` fails on drift.
- `nvim/` assumes the LazyVim starter was cloned into `~/.config/nvim` first.
- The vault is expected at `~/Projects/vault` (override with `OBSIDIAN_VAULT`) for the obsidian.nvim workflow.
- Git identity lives in the untracked per-host `~/.config/git/config.local`.
- `~/.config/opencode/` and `~/.config/opencode/themes/` must be real merge directories so `dotfiles-ai` and `opencode-wsl` can both link files inside them; shared AI harness runtime config stays in `dotfiles-ai`.
- Windows interop stays enabled in `/etc/wsl.conf`; the Neovim clipboard integration requires `clip.exe` and `powershell.exe`.
- Nerd Font rendering comes from the Windows-installed font via Windows Terminal; WSL needs no Linux font package.
- Baseline packages come from official Arch repos only; no AUR packages or AUR helper.
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

- the 2026-08-11 batch (tdl v3.8.4 resync, upstream cx/cy restore, TWIN_SPECS generalization, the `dw` workspace launcher, `yazi.toml` twin) was verified on the WSL host on 2026-08-11: `make restow`, `make verify`, and `make lint` pass (twin checks skipped, no local `dotfiles-omarchy` clone), and scripted tmux runs confirmed the `dw cc` and `dw oc` layout (windows `<agent>` / `editor+terminal`, 25% terminal pane focused in window 2, agent window selected, `@dw_root` set), `dw cc -c` typing `claude -c`, the bare-`dw` usage and re-attach paths, the arguments-ignored notice, and the root-mismatch guard; remaining eyes-on pass in a real Windows Terminal session: bare `dw` re-attach and in-tmux `switch-client`, `-c` actually resuming the agent conversation, and general rendering.
- the `tdl c` Neovim `E21` (README Troubleshooting) did not reproduce on 2026-08-11 in a scripted 220x50 detached-tmux run against the resynced `tdl` and OpenCode 1.17.7 (nvim pane sampled clean for 20s, all three panes stayed up); it is distinct from the historical E349 DCS passthrough issue (the local guard was removed as ineffective), and a detached session answers terminal queries itself, so rule it out only after an interactive `tdl c` in Windows Terminal; the Troubleshooting entry stays until then.
- next `/synchronize`: upstream `tdl` gained a trailing `select-pane -t "$opencode_pane"` referencing an undefined variable (introduced alongside `tds`); verify it is fixed before adopting upstream `tdl` changes.
- watch the tree-folded `~/.config/yazi`: the first `ya pkg` install writes `plugins/` and `package.toml` into the repo working tree; decide then whether to track them (the `dotfiles-ai` opencode-deps pattern) or gitignore them (the git-identity pattern already guarded by this repo's `.gitignore`).

## Skills

- `/synchronize` - sync this repo against Omarchy references and official WSL and Windows Terminal docs
