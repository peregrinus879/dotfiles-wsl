---
name: synchronize
description: Sync EyrWSL against Omarchy references and official WSL and Windows Terminal docs. Covers all packages owned by EyrWSL.
---

# Synchronize

Source configs from reference repos and official docs, compare against EyrWSL, and apply changes only where they belong in this repo.

## Sources

Local reference clones live under `~/Projects/quarry/`:

- `omarchy/` - main repo for bash, tmux, starship, git, fastfetch, btop, and editorconfig references
- `omarchy-pkgs/` - package builds, including the Omarchy Neovim package
- `gruvbox.nvim/` - Gruvbox Neovim plugin source selected by Omarchy
- `yazi/` - Yazi reference repo for configuration, theme, and feature changes
- `obsidian.nvim/` - obsidian.nvim upstream for the vault plugin spec
- `terminal/` - Windows Terminal reference repo for settings structure and feature changes

Upstream URLs, official docs, and descriptions live in `DEVIATIONS.md` (Reference Sources).

## When To Use

- Use this skill when Omarchy or a reference repo changed materially.
- Use this skill when repo scope or behavior changed materially.
- Use this skill when you suspect undocumented drift between this repo and its references.
- Use this skill before broad sync-oriented doc updates.

## Workflow

1. Compare reference repos against the packages owned by EyrWSL
2. For Omarchy-derived packages, compare against `omarchy/`, `omarchy-pkgs/`, and `gruvbox.nvim/`
3. For non-Omarchy tools, compare Yazi against `yazi/` and official docs, and the vault plugin specs against `obsidian.nvim/` and the render-markdown.nvim README
4. For Windows Terminal, compare `windows-terminal/settings.json` against `terminal/` and official docs
5. For each difference, classify it:
   - **Intentional deviation**: documented in `DEVIATIONS.md`, should stay different
   - **New upstream addition**: added upstream after the last sync, should be reviewed for inclusion
   - **Upstream change to existing config**: modified upstream, needs review
6. Check `git log --format="%h %ad %s" --date=short -- <file>` on the relevant reference repo when you need to determine when a difference was introduced
7. Cross-check differences against `DEVIATIONS.md`. If a difference is not documented there, treat it as a likely upstream change that needs review
8. Apply new upstream additions and changes where they belong in this repo
9. Update `README.md`, `AGENTS.md`, and `DEVIATIONS.md` when package ownership, setup steps, or documented deviations change
10. Summarize which changes were adopted, rejected, or intentionally kept different

## Completion Checks

- `README.md`, `AGENTS.md`, and `DEVIATIONS.md` reflect any ownership, setup, or workflow changes
- Every retained difference is still documented in `DEVIATIONS.md`
- The final summary distinguishes adopted changes, rejected changes, and intentional retained differences

## Rules

- Present proposed changes to the user before editing
- Omarchy, official docs, official package docs, and `DEVIATIONS.md` are the source of truth for default behavior and intentional differences
- Always check all relevant sources, not just one
- Never assume a difference is intentional without verifying it is documented in `DEVIATIONS.md`
- Keep the dual Gruvbox palette canons: terminal-side files track `themes/gruvbox/colors.toml` (`#7daea3` accent), while Neovim and the OpenCode theme track `gruvbox.nvim` (`#83a598` blue)
- Keep shared AI agent harness runtime config in EyrAgents; this repo owns only WSL-specific OpenCode theme availability
- Do not add AUR packages or an AUR helper; the baseline depends on official Arch repos only
- Keep Windows-specific behavior explicit and documented
