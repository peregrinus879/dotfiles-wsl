---
name: omasync
description: Sync EyrWSL against Omarchy references and official WSL and Windows Terminal docs. Covers all packages owned by EyrWSL.
---

# Omasync

Source configs from reference repos and official docs, compare against EyrWSL, and apply changes only where they belong in this repo.

## Sources

Local reference clones live under `~/Projects/quarry/`:

- `omarchy/` - main repo for bash, tmux, starship, git, fastfetch, btop, and editorconfig references; tracks the upstream default branch, which upstream moves between releases, so re-resolve its default branch and pin EyrWSL release comparisons to tag `v4.0.0` (`git show v4.0.0:<path>`)
- `omarchy-pkgs/` - package builds, including the Omarchy Neovim package
- `gruvbox.nvim/` - Gruvbox Neovim plugin source selected by Omarchy
- `yazi/` - Yazi reference repo for configuration and feature changes
- `obsidian.nvim/` - obsidian.nvim upstream for the vault plugin spec
- `terminal/` - Windows Terminal reference repo for settings structure and feature changes

Upstream URLs, official docs, and descriptions live in `DEVIATIONS.md` (Reference Sources). Durable findings and deferred items live in `docs/maintenance.md`.

## When To Use

- Use this skill when Omarchy or a reference repo changed materially.
- Use this skill when repo scope or behavior changed materially.
- Use this skill when you suspect undocumented drift between this repo and its references.
- Use this skill before broad sync-oriented doc updates.

## Workflow

1. Before updating any clone, require `git status --porcelain=v1 --untracked-files=all` to be empty in every listed reference clone and verify each `git remote get-url origin` against `DEVIATIONS.md`. Then, for each clone, run `git fetch --prune --tags origin`, `git remote set-head origin -a`, match the checkout to the resolved `refs/remotes/origin/HEAD`, run `git pull --ff-only`, and confirm `HEAD` equals `origin/<default>` and the worktree remains clean; require Omarchy tag `v4.0.0` to resolve locally
2. Compare reference repos against the packages owned by EyrWSL
3. For Omarchy-derived packages, compare against tag `v4.0.0` in `omarchy/`, plus `omarchy-pkgs/` and `gruvbox.nvim/`; never substitute moving-branch contents for the pinned release comparison
4. For non-Omarchy tools, compare Yazi against `yazi/` and official docs, and the vault plugin specs against `obsidian.nvim/` and the render-markdown.nvim README
5. Check the WSL and Windows contract against official WSL, Arch-on-WSL, and Windows Terminal docs: WSL2, Windows interop, `clip.exe`, `powershell.exe`, Windows-side font ownership, and `windows-terminal/settings.json` against `terminal/`; run `make wt-diff` when Terminal settings are involved
6. Check official-package ownership at maintenance time: run `pacman -Qo /usr/bin/codex /usr/bin/opencode`, re-probe with `pacman -Si claude-code` and `pacman -Si herdr` before retaining their canonical installers, and keep Yazi media helpers explicitly optional
7. For each difference, classify it:
   - **Intentional deviation**: documented in `DEVIATIONS.md`, should stay different
   - **New upstream addition**: added upstream after the last sync, should be reviewed for inclusion
   - **Upstream change to existing config**: modified upstream, needs review
8. Check `git log --format="%h %ad %s" --date=short -- <file>` on the relevant reference repo when you need to determine when a difference was introduced
9. Cross-check differences against `DEVIATIONS.md`. If a difference is not documented there, treat it as a likely upstream change that needs review
10. Apply new upstream additions and changes where they belong in this repo
11. Update `README.md`, `AGENTS.md`, `DEVIATIONS.md`, and `docs/maintenance.md` when ownership, setup, workflow, or durable maintenance findings change
12. Summarize which changes were adopted, rejected, or intentionally kept different

## Completion Checks

- `README.md`, `AGENTS.md`, and `DEVIATIONS.md` reflect any ownership, setup, or workflow changes
- Reference clones are clean, follow their resolved upstream default branches, and match `origin/<default>`; Omarchy release comparisons still use tag `v4.0.0`
- Every retained difference is still documented in `DEVIATIONS.md`
- Official-package probes and WSL/Windows gates reflect current sources; `make verify` and `make lint` pass, plus `make wt-diff` when Terminal settings are involved
- The final summary distinguishes adopted changes, rejected changes, and intentional retained differences

## Rules

- Present proposed changes to the user before editing
- Omarchy, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for default behavior and intentional differences
- Always check all relevant sources, not just one
- Never assume a difference is intentional without verifying it is documented in `DEVIATIONS.md`
- Fetch changeable upstream and package facts at maintenance time instead of caching versions in this skill
- Keep Windows Terminal and btop on Omarchy's semantic Gruvbox palette, Neovim on Omarchy's `gruvbox.nvim` selection, and ANSI-aware applications on terminal inheritance
- Keep shared AI agent harness and OpenCode TUI configuration in EyrAgents; this repo carries no custom OpenCode theme
- System packages, OpenCode, and Codex CLI come from official Arch repos; Claude Code and Herdr use canonical installers only while official packages are unavailable. No AUR packages or AUR helper.
- Keep Windows-specific behavior explicit. Anything that depends on `clip.exe`, `powershell.exe`, or Windows Terminal should be documented as a Windows interop concern.
