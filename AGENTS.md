# AGENTS.md - dotfiles-wsl

Self-contained WSL Arch dotfiles adapted from [Omarchy](https://github.com/basecamp/omarchy), managed with [GNU Stow](https://www.gnu.org/software/stow/): the full terminal baseline for Arch Linux inside WSL (Bash, Git, Neovim, tmux, starship, fastfetch, btop, editorconfig, Yazi), plus WSL and Windows-specific behavior (the OpenCode Miasma theme in `opencode-wsl/`, Windows Terminal configuration in `windows-terminal/`). Omarchy, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for default behavior and intentional differences; ownership boundaries live in `DEVIATIONS.md` (Deviation Policy and Out Of Scope).

## Load Map

- Claude Code loads this file through the root `CLAUDE.md` `@AGENTS.md` import; skills load on invocation only.
- The `Makefile` is the single source of the package list; `README.md` carries the human-facing setup, verification, and maintenance detail.
- Repo-root `.claude/settings.json` and `opencode.json` are per-tool project allowlists for this repo's verification make targets (`verify`, `lint`).

## Invariants

- Target machine: WSL; run stow and make targets only on the WSL host.
- When editing sibling dotfiles repos, use identical wording for shared concepts; only repo-specific values (scope, package lists, invariants) differ.
- The nvim vault plugin specs are byte-identical twins with `dotfiles-omarchy`; `make verify` fails on drift.
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

## Deferred Items

- watch basecamp/omarchy#5256 (upstream `tdl` DCS passthrough fix): when it merges, align the local `tdl` passthrough guard with upstream and update `DEVIATIONS.md`; the 50/50 split and second-AI-pane deviations stay regardless.
- check whether the `tdl c` Neovim `E21` (README Troubleshooting) still reproduces; it is distinct from the E349 DCS passthrough issue the `tdl` guard fixes, and the Troubleshooting entry stays until it is ruled out.
- next `/synchronize`: upstream `tdl` gained a trailing `select-pane -t "$opencode_pane"` referencing an undefined variable (introduced alongside `tds`); verify it is fixed before adopting upstream `tdl` changes.

## Skills

- `/synchronize` - sync this repo against Omarchy references and official WSL and Windows Terminal docs
