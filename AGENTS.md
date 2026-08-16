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

- next sync: upstream `tdl` ends with `select-pane -t "$opencode_pane"` on a variable it never sets, verified at v4.0.0 `default/bash/fns/tmux` on 2026-08-15 (cosmetic focus regression; `post-4.0-fixes` does not touch it); verify it is fixed before adopting upstream `tdl` changes.
- watch the tree-folded `~/.config/yazi`: the first `ya pkg` install writes `plugins/` and `package.toml` into the repo working tree; decide then whether to track them (the `dotfiles-ai` opencode-deps pattern) or gitignore them (the git-identity pattern already guarded by this repo's `.gitignore`).
- resync to the Omarchy quattro baseline: the Omarchy machine runs 4.0.0 (tag `v4.0.0`; the upstream default branch is `quattro`). Verified 3.8.4-to-quattro drift for this repo's packages (captured 2026-08-11 from the pre-release branch; re-verify against the release tag before adopting): aliases gain `c='opencode --auto'` and new `a`/`h` (and `mup`); fns drop `transcoding` and add `herdr`/`rsyncing`/`ssh-reconnect`; `tds` joins the tmux helpers (do not adopt `tdl`'s trailing select-pane bug, see the item above); completions are rewritten; envs adds EDITOR/BROWSER defaults, a locale fallback, and a PATH append; the fastfetch config moves to /etc with small content tweaks; starship/btop/git/editorconfig are zero diff; tmux.conf gains `-N` bind descriptions, a `?` keybindings popup, and the `*:clipboard` terminal-features line. Document the chosen baseline ref in `DEVIATIONS.md`.
- mirror the sibling skill: `dotfiles-omarchy`'s skill is named `omasync` and includes reference-clone maintenance (re-resolve the upstream default branch with `git remote set-head origin -a`) and a cross-repo ledger coordination step; rename and adapt this repo's skill to match, keeping repo-specific content.
- run the `dotfiles-ai` WSL host pass in the same sitting: its `docs/maintenance.md` deferred item carries the full runbook (pull, merge Codex trust entries, restow, per-tool verification); its step 1 assigns this repo the Codex installation-method choice (the Omarchy wrappers do not exist on WSL; on the Omarchy host they are mise wrappers).
- consider dropping the repo-root per-tool project allowlists (`.claude/settings.json`, `opencode.json`) as `dotfiles-omarchy` did on 2026-08-15 (its commit cead290); verification approvals are handled session-side.

## Skills

- `/synchronize` - sync this repo against Omarchy references and official WSL and Windows Terminal docs
