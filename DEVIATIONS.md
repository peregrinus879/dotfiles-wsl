# Deviations

## Purpose

This document records the intentional differences carried by EyrWSL relative to [Omarchy](https://github.com/basecamp/omarchy), and defines the boundary between this repo and its siblings.

Omarchy tag `v4.0.0` at commit `f0020448ca87329199de7cb12f2015ebc4a3e5e7` is the reproducible upstream comparison baseline. The lightweight tag names the release, while the commit ID records the exact reviewed source. Reference clones and the tag are maintenance inputs only; setup, Stow deployment, and verification do not use them.

## Deviation Policy

Omarchy is an opinionated Arch Linux distribution targeting a full desktop environment with Hyprland, systemd user services, GUI applications, and hardware-specific integrations. This repo extracts the terminal-layer configuration that remains useful inside WSL and restructures it into GNU Stow packages.

**Guiding principles:**

1. **Follow Omarchy conventions by default.** Aliases, keybindings, tmux layout ratios, and tool choices should stay close to Omarchy unless a WSL or non-desktop constraint requires a change.
2. **Adapt only what breaks or does not apply.** Desktop-bound behavior, GUI launchers, and hardware workflows are omitted because they do not fit WSL.
3. **Keep Windows-specific behavior explicit.** Anything that depends on `clip.exe`, `powershell.exe`, or Windows Terminal should be documented as a Windows interop concern.
4. **Use GNU Stow for dotfile management.** Omarchy uses direct file copies and packaged assets. This repo uses symlink-based package ownership for clearer separation and reuse.
5. **Single theme, no switching.** This repo uses Gruvbox only, so Omarchy's theme switching and hot-reload infrastructure is intentionally omitted.
6. **Pacman-first package ownership.** System packages, OpenCode, and Codex CLI come from official Arch repositories. Claude Code and Herdr use canonical standalone installers only while official packages are unavailable. The baseline depends on no AUR packages and installs no AUR helper.

## Reference Sources

- [basecamp/omarchy](https://github.com/basecamp/omarchy) - main repo for bash, tmux, starship, git, fastfetch, btop, and editorconfig references
- [omacom-io/omarchy-pkgs](https://github.com/omacom-io/omarchy-pkgs) - package builds, including the Omarchy Neovim package
- [OpenAI Codex](https://github.com/openai/codex) and the [Arch `openai-codex` package](https://archlinux.org/packages/extra/x86_64/openai-codex/) - official terminal CLI upstream and signed Arch package
- [OpenCode](https://github.com/anomalyco/opencode) and the [Arch `opencode` package](https://archlinux.org/packages/extra/x86_64/opencode/) - terminal coding agent upstream and signed Arch package
- [Herdr](https://github.com/herdrdev/herdr) - terminal workspace manager; its website provides the canonical installer
- [ellisonleao/gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) - Neovim colorscheme
- [microsoft/terminal](https://github.com/microsoft/terminal) - Windows Terminal settings structure and feature changes
- [sxyazi/yazi](https://github.com/sxyazi/yazi) and the [Yazi docs](https://yazi-rs.github.io/docs/) - file manager upstream and configuration reference
- [obsidian-nvim/obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim) - upstream for the vault plugin spec
- [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) - upstream for the markdown rendering spec
- [The Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual) - setup guides, keybindings, workflows
- [WSL Docs](https://learn.microsoft.com/en-us/windows/wsl/) - installation, configuration, and interop
- [Install Arch Linux on WSL](https://wiki.archlinux.org/title/Install_Arch_Linux_on_WSL) - Arch Wiki guide
- [Windows Terminal Docs](https://learn.microsoft.com/en-us/windows/terminal/) - settings, profiles, color schemes, and keybindings
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html) - symlink management and package structure
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html) - builtins, expansion, scripting
- [Starship Configuration](https://starship.rs/config/) - module options and format strings
- [Tmux Wiki](https://github.com/tmux/tmux/wiki) - usage and recipes
- [LazyVim Docs](https://www.lazyvim.org/) - installation, extras, and plugin conventions
- [Neovim Docs](https://neovim.io/doc/) - options, API, and Lua reference
- [lazy.nvim Docs](https://lazy.folke.io/) - plugin manager configuration
- [Git Docs](https://git-scm.com/docs) - config options and behavior
- [btop](https://github.com/aristocratos/btop) - config options and themes
- [fastfetch Wiki](https://github.com/fastfetch-cli/fastfetch/wiki) - modules and JSON config

Gruvbox follows Omarchy's behavior on each owned surface. Windows Terminal and btop use the semantic palette from `themes/gruvbox/colors.toml`; Neovim selects `ellisonleao/gruvbox.nvim`; tmux and Yazi use ANSI names resolved through Windows Terminal. OpenCode's `system` theme is selected by EyrAgents and inherits the same terminal palette.

## Intentional Deviations

### Environment Target

- Arch Linux inside WSL, not a full Omarchy desktop.
- Desktop services, GUI launchers, display manager integration, and Hyprland-specific behavior are intentionally excluded.
- Nerd Font rendering is a Windows-side concern. Windows Terminal uses the Windows-installed JetBrainsMono Nerd Font; WSL needs no Linux font package.

### Dotfile Management

- GNU Stow with symlinked package ownership replaces Omarchy's file-copy and package-install model.
- `make clean` performs an all-or-nothing ownership preflight and removes only links into EyrWSL or the sibling EyrAgents OpenCode package. Regular files, foreign or broken links, special files, and unrecognized repo-resolving parents abort untouched.
- `make verify` fails closed on the WSL2/interoperability host contract, command baseline, deployed package ownership, resolved Git identity, and owned config parsers and runtimes before running isolated attack fixtures.
- Git, Neovim, OpenCode, btop, and Yazi mutable or merge roots stay real; immutable package directories retain GNU Stow's normal tree-folding behavior.
- `/omasync` owns reference-clone maintenance and upstream comparison; `docs/maintenance.md` owns dated findings, known limitations, and deferred work.
- Agent-tool verification approvals are handled by session or shared EyrAgents policy rather than repo-root project allowlists.

### Theme

- Gruvbox is configured on Windows Terminal, btop, and Neovim; ANSI-aware applications inherit the terminal palette. Omarchy's multi-theme plugin set and theme hot-reload infrastructure are omitted.

### Terminal

- Windows Terminal replaces Ghostty from the Omarchy desktop.
- Gruvbox colors, JetBrainsMono Nerd Font at size 9, and padding 14 mirror Omarchy's terminal appearance in `windows-terminal/settings.json`.
- The Gruvbox color scheme maps Omarchy's semantic terminal palette to all 16 ANSI colors, cursor, selection, foreground, and background.
- `defaultProfile` uses the dynamic profile name `archlinux`; host-specific profile entries are omitted, and the `Windows.Terminal.Wsl` generator is disabled so the current `Microsoft.WSL` profile is unambiguous.
- Windows Terminal settings are never stowed. `make wt-push` resolves the active Windows account through PowerShell, validates both files, creates a timestamped adjacent backup only when they differ, and atomically deploys the tracked file; `make wt-diff` reports normalized drift without changing either side.

### Bash

- Config location is `~/.config/bash/` using an XDG-style layout instead of Omarchy's internal default path.
- Modular shell functions live in `~/.config/bash/functions/` and are sourced via a loop in `.bashrc`.
- Optional Bash overlays are sourced from `~/.config/bash-overlays/*` after the shared init. The directory is untracked and reserved for machine-local additions.
- Dropped aliases: `open` (GUI-only), `d='docker'`, and `r='rails'`.
- The kitty-conditional `ff` image-preview variant is omitted; Windows Terminal is not kitty, so the conditional would always take the plain `bat` branch kept here.
- Claude Code launches use the supported maximum effort, `--effort max`. The `claude` alias applies it to every interactive launch, including `cx` and `tdl`-launched AIs; scripts and hooks stay plain because they do not expand aliases.
- `y()` is added for Yazi cd-on-exit support. Yazi is not part of Omarchy.
- `tdw` is added: one tmux session per project (Git root, else current directory) with two windows: a full-width AI agent (`tdw cc` for Claude Code, `tdw oc` for OpenCode; the choice is mandatory at creation so a single agent owns the working tree) and `$EDITOR` above a 25% shell. `-c` continues that agent's last conversation in the project; bare `tdw` re-attaches an existing session. Creation checks the selected agent before changing tmux state. Additive alongside Omarchy's `tdl` pane layout. The `t`/`h` prefix follows Omarchy's multiplexer lettering (`tdl`/`hdl`).
- `hdw` is added: the Herdr counterpart of `tdw`, one workspace per project with the same agent and editor/shell layout, single-agent choice, continue flag, and root-collision guard. It starts a headless Herdr server when needed and falls back to attaching plain Herdr with a rerun hint.
- Omarchy's Herdr helpers `hdl`, `hdlm`, and `hsl` are adopted. `hds` is omitted because it invokes Hunk, which is outside the official-repository baseline.
- Omarchy's SSH port-forwarding, dropped-connection recovery, and rsync-on-change helpers are adopted. The rsync watcher is backed by the official `rsync` and `inotify-tools` packages.
- Interactive Bash exports `OPENCODE_DISABLE_EXTERNAL_SKILLS=1` and `OPENCODE_ENABLE_EXA=1` so terminal-launched OpenCode selects its EyrAgents-managed skills and configured web-search tool. Shell initialization removes inherited `$HOME/.opencode/bin` entries and appends approved user-level directories after existing system entries, so Pacman's OpenCode and Codex binaries retain precedence.
- Safe AI launch defaults intentionally differ from Omarchy: `c` remains plain OpenCode, `cx` uses Claude's reviewed `auto` permission mode, and `cy` honors EyrAgents' Codex defaults.
- `mise`-specific shell handling is omitted.
- No `pacman` alias and no AUR helper. Omarchy routes updates through `omarchy-update-perform`, which is Hyprland/desktop-bound; this repo uses plain `pacman` against official repos only.

### Git

- `~/.config/git/config` opens with `[include] path = ~/.config/git/config.local` so the local untracked `[user]` block is loaded first. Omarchy installs identity into the tracked file directly during install.
- `[init] defaultBranch = main` replaces Omarchy's `master`.
- Inline option comments are removed because the same intent is captured in this file. Omarchy keeps inline comments next to each option.
- Private Git identity is intentionally not tracked. WSL uses the untracked local file `~/.config/git/config.local` for `[user]` name and email.

### Starship

- The prompt shows `hostname` only during SSH sessions so remote shells are visually distinct from local ones while keeping the local prompt minimal.
- The `conflicted`, `up_to_date`, and `modified` Git status icons use Material Design Icons codepoints instead of Omarchy's Nerd Font private-use codepoints, matching the same broader-terminal-font compatibility rationale used for Fastfetch.

### Tmux

- Upstream's `M-Enter`, `M-S-Enter`, and `M-Escape` pane bindings are adopted verbatim; `alt+enter` is unbound in `windows-terminal/settings.json` (`"id": null`) because Windows Terminal's default binds it to fullscreen and would swallow `M-Enter` before it reaches tmux.
- The `?` keybindings-popup binding is omitted; it shells out to `omarchy-menu-tmux-keybindings`, which exists only on an Omarchy install.
- Omarchy's binding descriptions, generic clipboard feature, and terminal title settings are adopted. The Kitty-only extended-key feature is omitted because Windows Terminal is the host terminal.

### Tmux Dev Layout

- `tdl`, `tdlm`, and `tsl` retain Omarchy's terminal layouts. `tdl` selects `editor_pane` rather than the upstream baseline's unset `opencode_pane`; Hunk-dependent `tds` is omitted.

### Neovim

- `lua/config/options.lua` keeps Omarchy's `vim.opt.relativenumber = false` and `vim.g.autoformat = false` baseline and adds WSL clipboard integration directly, guarded by `clip.exe` and `powershell.exe` availability so the block is a no-op outside WSL. Copy uses `clip.exe`; paste uses `powershell.exe Get-Clipboard`.
- The `nvim/` package owns the complete LazyVim bootstrap, static configuration, and generated `lazy-lock.json`; setup requires no separate Neovim configuration clone.
- `all-themes.lua` and `omarchy-theme-hotreload.lua` are omitted because Neovim uses a fixed Gruvbox configuration.
- Kept verbatim from `omarchy-nvim`: `disable-news-alert.lua`, `snacks-animated-scrolling-off.lua`, `vim.opt.relativenumber = false`, and `vim.g.autoformat = false`.
- `transparency.lua` content is verbatim from `omarchy-nvim` but lives at `after/plugin/` instead of upstream's `plugin/after/` to use Neovim's actual after-load mechanism. Upstream `omarchy-nvim` uses the incorrect path.
- Owned Lua files use 2-space indentation per the shared `.editorconfig` in this repo. Upstream `omarchy-nvim` uses tabs. Contents are otherwise unchanged.
- Two additive plugin specs are carried: `obsidian.lua` (obsidian.nvim against the vault at `~/Projects/vault`, override with `OBSIDIAN_VAULT`) and `render-markdown.lua` (visual markdown rendering companion). `python` is in the baseline package list because the vault keybindings shell out to the vault's `normalize.py`.
- The spec's `open.func` routes `obsidian://` and web URIs through Windows interop (`powershell.exe Start-Process`) when running under WSL, so `:Obsidian open` and link-following reach the Windows apps without `wsl-open`, which is not in official Arch repos. The override is guarded by `vim.fn.has("wsl")` and inert elsewhere.

### OpenCode

- Shared OpenCode runtime and TUI configuration remains owned by EyrAgents. Its `system` theme selection uses ANSI colors and terminal defaults, matching Omarchy's terminal-aware behavior without a custom palette in EyrWSL.
- `~/.config/opencode/` stays a real directory so EyrAgents can link configuration while OpenCode manages its runtime content.

### Fastfetch

- Fastfetch is rewritten for a terminal-first environment instead of Omarchy's desktop-oriented presentation.
- The same box-drawing structure and section layout are kept: Hardware, Software, and Uptime.
- Desktop modules are omitted: `display`, `wm`, `de`, and `wmtheme`.
- Omarchy-specific helper commands are omitted: `omarchy-version`, `omarchy-version-branch`, `omarchy-version-channel`, `omarchy-version-pkgs`, and `omarchy-theme-current`.
- `OS Age` is omitted.
- Omarchy's ASCII logo is replaced with fastfetch's built-in small logo.
- Icon codepoints use the Material Design Icons range for broader terminal font compatibility.
- Standard modules `shell` and `os` are added.
- `display.disableLinewrap` follows the Omarchy baseline so long values do not disturb the box layout.

### Btop

- `btop.conf` is based on the generated config format produced by `btop`, including lowercase booleans and additional default settings.
- The intentional baseline change is `color_theme = "gruvbox"` instead of Omarchy's `"current"`; `gruvbox.theme` is the stable Omarchy template rendered with the stable semantic palette.

### Yazi

- Added entirely. Yazi is not part of Omarchy.
- `yazi.toml` keeps the local layout and behavior choices: ratio `[2, 4, 4]`, hidden files shown, directories sorted first, `sort_by = "natural"`, and `linemode = "size"`.
- Yazi's built-in theme uses named ANSI colors for its primary interface, so Windows Terminal supplies the Gruvbox palette without a local theme override.

### WSL Bootstrap

- `/etc/wsl.conf` carries the default user and keeps Windows interop enabled, which the clipboard integration requires.
- Windows-side installation of Windows Terminal, the Nerd Font, and Arch directly through `wsl --install -d archlinux` is documented in this repo's README; WSL2 and a root recovery password are setup gates.
- The WSL baseline includes `inetutils` for the `hostname` host gate, `lua` for EyrWSL's fail-closed syntax verification, `nodejs` for EyrAgents verification, `tree-sitter-cli` for LazyVim, and `man-db`/`man-pages` for local documentation. The official `openai-codex` and `opencode` packages own the AI terminal binaries.
- Yazi media helpers are optional official packages, not hidden baseline dependencies.

## Skipped From Omarchy

- GUI and desktop components, including Hyprland, Waybar, SDDM, Plymouth, Mako, Walker, Fcitx5, and related user services
- SwayOSD, hardware drivers, Elephant widgets, and other desktop-bound integrations
- `omarchy-fish`, `omarchy-zsh`, and `omarchy-walker`
- `drives` functions such as `iso2sd` and `format-drive`
- `transcoding` functions for video and image conversion
- Hunk-dependent `tds` and `hds` layouts
- Omarchy's `open`, `a`, and `mup` shell helpers, which depend on desktop launchers, `omarchy-agent`, or mise
- Hardware-focused tooling and desktop automation
- Theme switching infrastructure not needed for fixed per-surface themes
- Shell or app packages outside the chosen Bash plus terminal-tooling baseline

## Out Of Scope

The following do **not** belong in EyrWSL:

- Shared AI agent runtime configuration (belongs in EyrAgents)
- Omarchy desktop customizations such as Hyprland bindings (belong in EyrArcHy)
