# dotfiles-wsl

Self-contained Arch Linux dotfiles for WSL, adapted from [Omarchy](https://github.com/basecamp/omarchy), managed with [GNU Stow](https://www.gnu.org/software/stow/).

`dotfiles-wsl` carries the full terminal baseline for Arch Linux running inside WSL, plus the WSL and Windows-specific pieces: Windows Terminal, clipboard integration, and OpenCode theme availability. It keeps Omarchy's terminal tooling and general feel while dropping desktop-specific components that do not apply inside WSL.

## Repo Family

Derivation model for this repo family:

```text
AI harness configs              → dotfiles-ai
Omarchy + personal deviations   → dotfiles-omarchy
Omarchy + WSL deviations        → dotfiles-wsl
```

- [`dotfiles-ai`](https://github.com/peregrinus879/dotfiles-ai) - AI harness configs: Claude Code and OpenCode settings, shared guidance, and commit workflow
- [`dotfiles-omarchy`](https://github.com/peregrinus879/dotfiles-omarchy) - Personal Omarchy customizations: Bash overrides, Hyprland bindings, Neovim plugins, and Yazi
- [`dotfiles-wsl`](https://github.com/peregrinus879/dotfiles-wsl) - Self-contained WSL Arch dotfiles: terminal baseline plus Windows Terminal, clipboard integration, and OpenCode theme

## Stack

- **Shell**: [Bash](https://www.gnu.org/software/bash/)
- **Prompt**: [Starship](https://github.com/starship/starship)
- **Multiplexer**: [Tmux](https://github.com/tmux/tmux)
- **Editor**: [Neovim](https://github.com/neovim/neovim) ([LazyVim](https://github.com/LazyVim/LazyVim))
- **Version Control**: [Git](https://git-scm.com/), [GitHub CLI](https://cli.github.com/), [LazyGit](https://github.com/jesseduffield/lazygit)
- **File Manager**: [Yazi](https://github.com/sxyazi/yazi), [eza](https://github.com/eza-community/eza), [zoxide](https://github.com/ajeetdsouza/zoxide)
- **Search and Preview**: [fd](https://github.com/sharkdp/fd), [fzf](https://github.com/junegunn/fzf), [bat](https://github.com/sharkdp/bat), [ripgrep](https://github.com/BurntSushi/ripgrep)
- **System Monitor**: [btop](https://github.com/aristocratos/btop)
- **System Info**: [fastfetch](https://github.com/fastfetch-cli/fastfetch)
- **Dotfile Management**: [GNU Stow](https://www.gnu.org/software/stow/)
- **Terminal**: [Windows Terminal](https://github.com/microsoft/terminal)
- **Theme**: [Miasma](https://github.com/OldJobobo/miasma.nvim)

## Package Layout

Each top-level directory is a GNU Stow package that symlinks into `$HOME`, except `windows-terminal/`, which is applied manually on Windows:

```text
bash/              Shell config (.bashrc, .inputrc, .config/bash/)
btop/              System monitor config (btop.conf, themes/miasma.theme)
editorconfig/      Editor formatting rules (.editorconfig)
fastfetch/         System info config (config.jsonc)
git/               Git config (config, ignore)
nvim/              Neovim config (lazyvim.json, lua/config/, lua/plugins/, after/plugin/)
opencode-wsl/      OpenCode Miasma theme (themes/miasma.json)
starship/          Prompt config (starship.toml)
tmux/              Tmux config (tmux.conf)
yazi/              File manager config (yazi.toml, theme.toml)
windows-terminal/  Windows Terminal settings.json, applied manually, not stowed
```

Key ownership rules:

- `nvim/` owns the full Neovim config, including `lua/config/options.lua` with the built-in WSL clipboard integration
- `nvim/` includes the vault plugin specs (`obsidian.lua`, `render-markdown.lua`); the vault is expected at `~/Projects/vault` (override with `OBSIDIAN_VAULT`)
- Bash supports additive machine overlays through `~/.config/bash-overlays/*`; the directory is optional and reserved for untracked machine-local additions
- `dotfiles-ai` keeps ownership of shared OpenCode runtime config; `opencode-wsl/` only adds Miasma theme availability without forcing the selected theme
- `~/.config/opencode/` and `~/.config/opencode/themes/` must be real merge directories so `dotfiles-ai` and `opencode-wsl` can both link files inside them
- `windows-terminal/` stays Windows-side, is applied manually, and intentionally tracks the full paste-ready `settings.json`
- repo-root `.claude/settings.json` and `opencode.json` are per-tool project allowlists for the repo's read-only make targets; they are not stowed

## Setup

### 1. Windows and WSL

Open PowerShell as Administrator, then install the Nerd Font and WSL:

```powershell
winget install DEVCOM.JetBrainsMonoNerdFont
wsl --install
```

Windows Terminal uses the Windows-installed Nerd Font directly. WSL does not need a separate Linux font package for `tmux`, `nvim`, `yazi`, `starship`, or `fastfetch` icons to render correctly.

Restart Windows if prompted, then install Arch Linux with the distro-specific `-d` form documented by Microsoft:

```powershell
wsl --install -d archlinux
```

### 2. WSL Initial Setup

On first launch, Arch runs as root. Update the system and create your user:

```bash
pacman -Syu
pacman -S --needed git neovim openssh sudo
useradd -m -G wheel -s /bin/bash <username>
passwd <username>
EDITOR=nvim visudo
```

Uncomment this line in `visudo`:

```text
%wheel ALL=(ALL:ALL) ALL
```

Set the default user and keep Windows interop enabled in `/etc/wsl.conf`:

```ini
[user]
default = <username>

[interop]
enabled = true
```

Restart WSL from PowerShell so `/etc/wsl.conf` changes are applied:

```powershell
wsl --shutdown
```

### 3. Locale

Generate the `en_US.UTF-8` locale to avoid perl and stow warnings:

```bash
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
```

### 4. Prerequisites

Install the baseline packages required by these dotfiles:

```bash
sudo pacman -S --needed bash-completion bat btop diffutils eza fastfetch fd fzf gcc git github-cli \
  gum jq lazygit less make neovim openssh python ripgrep shellcheck starship stow sudo tmux unzip \
  which yazi zoxide
```

All baseline packages come from official Arch repositories. This repo intentionally depends on no AUR packages and installs no AUR helper.

### 5. Clone

Recommended local layout for this repo family:

```text
~/Projects/repos/dotfiles/dotfiles-wsl
```

Stow can work from any clone location, but the related docs and cross-repo maintenance workflows assume this layout.

```bash
git clone https://github.com/peregrinus879/dotfiles-wsl.git ~/Projects/repos/dotfiles/dotfiles-wsl
```

### 6. Neovim Base

Clone the LazyVim starter first so the `nvim/` package has a target directory to extend:

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

### 7. Private Git Identity

Tracked Git config intentionally excludes `[user]` identity. Create a local untracked file before using Git:

```bash
mkdir -p ~/.config/git
```

Create `~/.config/git/config.local` with your local identity:

```ini
[user]
  name = Your Name
  email = your-email@example.com
```

### 8. Prepare

Checklist before stowing:

- Required packages are installed
- `dotfiles-wsl` was cloned locally
- LazyVim starter was cloned into `~/.config/nvim`
- `~/.config/git/config.local` exists with your local Git identity
- `dotfiles-ai` OpenCode config is already stowed if you use OpenCode on this WSL install
- Any existing conflicting files were removed

Remove existing files that would conflict with stow. The first block removes tree-folded directory symlinks left by a previous stow; entries that are already real directories (such as `~/.config/git` after step 7) error harmlessly and are left in place. The second block prepares shared OpenCode merge directories, then re-stows `dotfiles-ai` when present so any shared OpenCode entries remain linked there. The final block removes individual config files:

```bash
# Tree-folded directory symlinks (from a previous stow)
rm -f ~/.config/bash ~/.config/btop ~/.config/fastfetch ~/.config/git \
  ~/.config/nvim/after ~/.config/tmux ~/.config/yazi

# Shared merge directories
if [[ -L ~/.config/opencode ]]; then
  rm -f ~/.config/opencode
fi
mkdir -p ~/.config/opencode
if [[ -L ~/.config/opencode/themes ]]; then
  rm -f ~/.config/opencode/themes
fi
mkdir -p ~/.config/opencode/themes

if [[ -d ~/Projects/repos/dotfiles/dotfiles-ai ]]; then
  (cd ~/Projects/repos/dotfiles/dotfiles-ai && stow -v -t ~ opencode)
fi

# Individual config files
rm -f ~/.bashrc ~/.inputrc
rm -f ~/.editorconfig
rm -f ~/.config/git/config ~/.config/git/ignore
rm -f ~/.config/starship.toml
rm -f ~/.config/tmux/tmux.conf
rm -f ~/.config/fastfetch/config.jsonc
rm -f ~/.config/btop/btop.conf ~/.config/btop/themes/miasma.theme
rm -f ~/.config/yazi/yazi.toml ~/.config/yazi/theme.toml
rm -f ~/.config/nvim/lazyvim.json
rm -f ~/.config/nvim/lua/config/options.lua
rm -f ~/.config/nvim/lua/plugins/example.lua
rm -f ~/.config/nvim/lua/plugins/colorscheme.lua
rm -f ~/.config/nvim/lua/plugins/disable-news-alert.lua
rm -f ~/.config/nvim/lua/plugins/snacks-animated-scrolling-off.lua
rm -f ~/.config/nvim/lua/plugins/obsidian.lua
rm -f ~/.config/nvim/lua/plugins/render-markdown.lua
rm -f ~/.config/nvim/after/plugin/transparency.lua
rm -f ~/.config/opencode/themes/miasma.json
```

### 9. Stow

Create symlinks for all packages:

```bash
cd ~/Projects/repos/dotfiles/dotfiles-wsl
stow -v -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
```

Start a new terminal session, or run `source ~/.bashrc`, for the shell config to take effect.

### Unstow

```bash
cd ~/Projects/repos/dotfiles/dotfiles-wsl
stow -D -v -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
```

### Dry Run

Preview what stow would do without making changes:

```bash
cd ~/Projects/repos/dotfiles/dotfiles-wsl
stow -v -n -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
```

### Re-stow

To update symlinks after the repo content changes (same clone path):

```bash
cd ~/Projects/repos/dotfiles/dotfiles-wsl
stow -R -v -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
```

To migrate from a different clone path, unstow from the old location first:

```bash
cd /old/clone/path
stow -D -v -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
cd ~/Projects/repos/dotfiles/dotfiles-wsl
stow -v -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
```

If the old clone is no longer available, run the full cleanup in section 8 before stowing.

### 10. First Launch

Open Neovim once to trigger plugin installation:

```bash
nvim
```

### 11. Windows Terminal

Open Windows Terminal settings JSON with `Ctrl+Shift+,` and replace the contents with `windows-terminal/settings.json`.

This repo intentionally tracks the full `settings.json` so it can be copied and pasted as-is without reconstructing a partial JSON fragment.

After pasting on a fresh Windows install, confirm the default profile still resolves to `archlinux`; if Windows Terminal warns about a missing default profile, re-select it once in the settings UI.

Alternatively, edit the file directly at:

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

## Verify

After stowing:

- Confirm the core symlinks and local Git identity exist: `test -L ~/.bashrc && test -L ~/.config/starship.toml && test -L ~/.config/nvim/lua/config/options.lua && test -f ~/.config/git/config.local`
- Confirm the OpenCode theme symlink exists: `test -L ~/.config/opencode/themes/miasma.json`
- Start a fresh shell and confirm Bash, Starship, and Tmux load without errors.
- Run `nvim` once and confirm plugins install successfully and Miasma loads.
- In Neovim, confirm yanks reach the Windows clipboard and pastes from the Windows clipboard reach Neovim.
- If the vault is synced to this machine, open a vault note and confirm obsidian.nvim loads (`<leader>oo` opens the note switcher).
- In OpenCode, run `/theme` and confirm `miasma` is available. Select it if OpenCode is still using the `system` theme.
- Confirm Windows Terminal uses JetBrainsMono Nerd Font and the Miasma color scheme after applying `windows-terminal/settings.json`.

## Troubleshooting

- **`stow` reports "existing target is not a symlink"**: Remove the conflicting file listed in the error, then re-run the stow command. Section 8 lists the expected cleanup targets.
- **Neovim clipboard not working**: Confirm `clip.exe` and `powershell.exe` are accessible from WSL (`which clip.exe`). If Windows interop is disabled, check `[interop]` in `/etc/wsl.conf`.
- **OpenCode Miasma not listed**: Confirm `~/.config/opencode/themes/miasma.json` is a symlink to `opencode-wsl/.config/opencode/themes/miasma.json`. If `~/.config/opencode` or `~/.config/opencode/themes` is still a directory symlink to another dotfiles package, repeat the merge directory prep in section 8, then re-run the stow command.
- **`tdl c` still reports Neovim `E21` after selecting Miasma**: Treat the theme as ruled out and investigate the tmux/OpenCode startup path separately.

## Maintenance

A repo-root `Makefile` keeps the package list in one place and wraps the routine commands. Run targets from the repo root on the WSL machine:

- `make stow` / `make unstow` / `make dry-run` / `make restow` - the stow command sets from Setup
- `make stow-all` - stows `dotfiles-ai`'s `opencode` package first, then all packages here
- `make verify` - the Verify symlink and identity checks plus shell and Lua syntax checks (the Lua checks need the optional `lua` package for `luac` and are skipped otherwise)
- `make clean` - the Prepare cleanup steps
- `make lint` - ShellCheck over the bash package and `scripts/`; `.shellcheckrc` disables the pre-existing upstream-derived warnings so new issues stand out
- `make wt-diff` - diff the tracked Windows Terminal settings against the deployed Windows-side file (normalized with `jq`, since Windows Terminal rewrites key order)
- `make wt-pull` - copy the deployed Windows Terminal settings into the repo for review with `git diff`

## References

- `README.md` - package layout, setup, and verification
- `Makefile` - stow, verification, cleanup, lint, and drift-detection automation
- `scripts/wt-diff.sh` - Windows Terminal settings drift detection
- `DEVIATIONS.md` - intentional deviations from Omarchy and boundary definitions
- `AGENTS.md` - canonical repo-specific assistant context and maintainer checklist
- `CLAUDE.md` - thin Claude Code wrapper importing `AGENTS.md`
- `opencode-wsl/.config/opencode/themes/miasma.json` - OpenCode Miasma theme

## Related Repos

Clone these locally if you plan to use `/synchronize` or compare against upstream references. The `/synchronize` skill expects reference repos under `~/Projects/repos/references/`.

- `~/Projects/repos/references/omarchy` - upstream Omarchy reference repo
- `~/Projects/repos/references/omarchy-pkgs` - upstream package reference repo
- `~/Projects/repos/references/miasma.nvim` - Miasma theme reference repo (the `OldJobobo/miasma.nvim` fork used by Omarchy)
- `~/Projects/repos/references/yazi` - Yazi reference repo
- `~/Projects/repos/references/obsidian.nvim` - obsidian.nvim reference repo for the vault plugin spec
- `~/Projects/repos/references/terminal` - Windows Terminal reference repo

## Credits

Adapted from [Omarchy](https://github.com/basecamp/omarchy). See [DEVIATIONS.md](DEVIATIONS.md) for intentional differences and boundary definitions.

## License

[MIT](LICENSE)
