# Maintenance Ledger - EyrWSL

Unresolved decisions, deferred work, active limitations, and the dated evidence behind them. Durable rules live in `AGENTS.md`, `DEVIATIONS.md`, a skill, a script header, or a test; remove an item here once its rule has moved there.

## Active Limitations

- `:Obsidian paste_img` expects `wl-clipboard` or `xclip`, unavailable under WSL.

## Deferred Work

- WSL host pass, for the agent to run in a session opened in the WSL clone, stopping at the first mismatch: `git pull --ff-only`; `make restow` (Stow replaces the folded parents of the previous deployment with real directories and leaf links, so expect it to unlink and relink every package; `~/.config/opencode` stays untouched); `make verify`; `make refs` (clones `gruvbox.nvim` and removes clones no family repository lists); `make wt-diff`; then `make stow` and `make verify` in the EyrAgents clone as its own ledger describes. Report the results and remove this item.
