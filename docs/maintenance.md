# Maintenance Ledger - EyrWSL

Unresolved decisions, deferred work, active limitations, and the dated evidence behind them. Durable rules live in `AGENTS.md`, `DEVIATIONS.md`, a skill, a script header, or a test; remove an item here once its rule has moved there.

## Active Limitations

- `:Obsidian paste_img` expects `wl-clipboard` or `xclip`, unavailable under WSL.

## Deferred Work

- WSL host pass, for the agent to run in a session opened in the WSL clone, stopping at the first mismatch. H runs the `sudo` and removal commands after the agent presents each target:
  1. `git pull --ff-only`.
  2. `sudo pacman -S --needed mise`, then `sudo pacman -Rns openai-codex opencode`.
  3. Remove the standalone Claude Code launcher and versions store: `rm -f ~/.local/bin/claude`, `rm -rf ~/.local/share/claude`, and `rm -rf ~/.claude/bin` if that older launcher directory exists. `~/.claude` settings and credentials stay.
  4. `make clean`: it removes the previous folded deployment's parent links and reports any leftover at `~/.local/bin/claude`, `codex`, or `opencode`.
  5. `make restow`: Stow replaces the folded parents with real directories and leaf links (expect every package to unlink and relink), links the three `mise` wrappers, and creates `~/.config/mise/conf.d` for the paranoid-mode fragment before any wrapper writes `config.toml`; `~/.config/opencode` stays untouched.
  6. Open a fresh shell and confirm `mise settings get paranoid` prints `true`; run `claude`, `codex`, and `opencode` once each so the wrappers install the tools (network required; with the 24-hour cooldown each installs the newest release older than a day; any project-level mise config on the host is refused until `mise trust`).
  7. `make verify`; `make refs` (clones `gruvbox.nvim` and removes clones no family repository lists); `make wt-diff`.
  8. `make stow` and `make verify` in the EyrAgents clone as its own ledger describes, then the EyrAgents wording item below.
  Report the results and remove this item.
- EyrAgents still describes the WSL install as the official `openai-codex` package plus the Claude Code installer under `~/.claude/bin` (its `README.md` host requirements and its ledger's WSL host pass, checked 2026-09-03). After the host pass above, update those to the mise layout so both hosts read the same way; that edit belongs to the EyrAgents clone.
- Move the Omarchy comparison pin: `DEVIATIONS.md` and the `/omasync` skill pin `v4.0.0` while the packaged Omarchy is at 4.0.2-1 (2026-09-03). On the WSL host, run `/omasync` comparing the owned packages between `v4.0.0` and the current release tag, adopt or record each difference, then move the pin in the `DEVIATIONS.md` baseline paragraph and the skill's steps 1 and 3 and completion check. The `mise/` wrappers follow v4.0.2's `omarchy-mise-install` form (`mise use -g --quiet`, added after v4.0.0) minus the cooldown export, a documented deviation; the pin move closes the `--quiet` gap rather than opening one.

## Revalidation Triggers

- Each Omarchy release (the newest tag in `~/Projects/quarry/omarchy` after `make refs`): rerun `/omasync` against the pin and decide whether to move it, then `make verify` on the WSL host.
