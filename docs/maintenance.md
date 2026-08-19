# Maintenance Ledger - EyrWSL

Read this file before package changes, WSL or Windows Terminal updates, `/omasync`, work on a deferred item, or cross-repo coordination. Current operational policy stays in `AGENTS.md`; this ledger carries dated findings, known limitations, and deferred items. It records repo decisions and behavior official docs do not state; doc-derivable facts such as defaults, version gates, package availability, and upstream status are fetched at change time, not cached here.

## Known Limitations

- `:Obsidian paste_img` expects `wl-clipboard` or `xclip`, unavailable under WSL.
- Stow tree-folds immutable config directories that do not pre-exist at stow time into package symlinks. Guarded preparation keeps Git, Neovim, OpenCode, btop, and Yazi mutable or merge roots real; folding remains the convention for the other package directories (do not add `--no-folding`).
