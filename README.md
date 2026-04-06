# dotfiles-wsl

WSL overlay for [`dotfiles-arch`](https://github.com/peregrinus879/dotfiles-arch) (Arch Linux), managed with [GNU Stow](https://www.gnu.org/software/stow/).

`dotfiles-wsl` is the additive WSL and Windows-specific overlay on top of `dotfiles-arch`. It owns only the WSL-specific and Windows-specific pieces needed to finish the setup on Arch Linux running inside WSL while preserving the shared baseline.

This repo does not replace the shared Linux baseline. Complete `dotfiles-arch` first, then layer this overlay on top.

## Repo Family

- [`dotfiles-ai`](https://github.com/peregrinus879/dotfiles-ai) - Claude Code and OpenCode global dotfiles, managed with GNU Stow
- [`dotfiles-arch`](https://github.com/peregrinus879/dotfiles-arch) - Headless Arch Linux dotfiles adapted from Omarchy, managed with GNU Stow
- [`dotfiles-wsl`](https://github.com/peregrinus879/dotfiles-wsl) - WSL overlay for dotfiles-arch (Arch Linux), managed with GNU Stow
- [`dotfiles-omarchy`](https://github.com/peregrinus879/dotfiles-omarchy) - Omarchy personal dotfiles, managed with GNU Stow

## Stack

- **Base Layer**: `dotfiles-arch`
- **Terminal**: [Windows Terminal](https://github.com/microsoft/terminal)
- **Shell Overlay**: Bash repo auto-refresh enablement for `~/projects/repos`
- **Editor Overlay**: [Neovim](https://github.com/neovim/neovim) WSL clipboard integration
- **Theme**: [Miasma](https://github.com/xero/miasma.nvim)

## Package Layout

Each top-level directory is either a GNU Stow package or a manually applied config:

```text
bash-wsl/          WSL Bash overlay (enables repo auto-refresh)
nvim-wsl/          WSL-specific Neovim overlay (adds lua/config/overlay.lua)
windows-terminal/  Windows Terminal settings.json, applied manually, not stowed
```

Key ownership rules:

- `dotfiles-arch` keeps ownership of shared Bash and Neovim behavior
- `bash-wsl/` only enables WSL-side repo auto-refresh for the shared Bash helper
- `nvim-wsl/` only adds `lua/config/overlay.lua` for WSL clipboard integration; loaded automatically by `dotfiles-arch`'s `lua/config/options.lua` when present
- `windows-terminal/` stays Windows-side, is applied manually, and intentionally tracks the full paste-ready `settings.json`

## Setup

### 1. Windows and WSL

Install the Nerd Font and WSL from PowerShell:

```powershell
winget install DEVCOM.JetBrainsMonoNerdFont
wsl --install
```

Windows Terminal uses the Windows-installed Nerd Font directly. WSL does not need a separate Linux font package for `tmux`, `nvim`, `yazi`, `starship`, or `fastfetch` icons to render correctly.

Restart Windows if prompted, then install Arch Linux:

```powershell
wsl --install archlinux
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

Restart WSL from PowerShell:

```powershell
wsl --shutdown
```

### 3. Locale

Generate the `en_US.UTF-8` locale to avoid perl and stow warnings:

```bash
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
```

### 4. Apply `dotfiles-arch` First

Before using this repo, complete the full `dotfiles-arch` setup first:

- install the baseline packages
- clone the LazyVim starter into `~/.config/nvim`
- create `~/.config/git/config.local`
- clone `dotfiles-arch`
- run the Arch baseline stow command

On WSL, apply the shared baseline packages from `dotfiles-arch`:

```bash
cd ~/projects/repos/dotfiles/dotfiles-arch
stow -v -t ~ bash btop editorconfig fastfetch git nvim starship tmux yazi
```

This repo assumes the shared shell, tmux, git, fastfetch, btop, Yazi, and shared Neovim config already come from `dotfiles-arch`.

### 5. Clone

Recommended local layout for this repo family:

```text
~/projects/repos/dotfiles/dotfiles-wsl
```

Stow can work from any clone location, but the related docs and cross-repo maintenance workflows assume this layout.

```bash
git clone https://github.com/peregrinus879/dotfiles-wsl.git ~/projects/repos/dotfiles/dotfiles-wsl
```

### 6. Prepare Overlay

Checklist before stowing the overlay:

- `dotfiles-arch` prerequisites and shared baseline stow are already complete
- `~/.config/nvim` exists as a real LazyVim starter directory
- Any existing conflicting WSL overlay files were removed

Remove any existing conflicting WSL overlay files:

```bash
rm -f ~/.config/bash-overlays/20-repo-auto-refresh
rm -f ~/.config/nvim/lua/config/overlay.lua
```

### 7. Stow

Stow the WSL overlay packages:

```bash
cd ~/projects/repos/dotfiles/dotfiles-wsl
stow -v -t ~ bash-wsl nvim-wsl
```

### Unstow

```bash
cd ~/projects/repos/dotfiles/dotfiles-wsl
stow -D -v -t ~ bash-wsl nvim-wsl
```

### Dry Run

Preview what stow would do without making changes:

```bash
cd ~/projects/repos/dotfiles/dotfiles-wsl
stow -v -n -t ~ bash-wsl nvim-wsl
```

### 8. Bash Auto-Refresh

`bash-wsl/` enables the shared repo auto-refresh helper from `dotfiles-arch`.

Behavior:

- only checks repos under `~/projects/repos`
- runs when the shell prompt returns after you change directories
- fetches remote updates quietly
- fast-forwards only when the repo is clean and behind upstream only
- warns and skips when the repo is dirty, diverged, detached, or mid-operation

Optional tuning:

```bash
export REPO_AUTO_REFRESH_INTERVAL=300
export REPO_AUTO_REFRESH_ROOT="$HOME/projects/repos"
```

Manual refresh for the current repo:

```bash
repo-refresh-now
```

### 9. Windows Terminal

Open Windows Terminal settings JSON with `Ctrl+Shift+,` and replace the contents with `windows-terminal/settings.json`.

This repo intentionally tracks the full `settings.json` so it can be copied and pasted as-is without reconstructing a partial JSON fragment.

Alternatively, edit the file directly at:

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

### 10. Private Git Identity

The shared Git config from `dotfiles-arch` expects private identity to live in an untracked local file:

```text
~/.config/git/config.local
```

Example:

```ini
[user]
  name = Your Name
  email = your-email@example.com
```

## Verify

After applying the baseline and the overlay:

- Confirm the overlay symlinks exist: `test -L ~/.config/bash-overlays/20-repo-auto-refresh && test -L ~/.config/nvim/lua/config/overlay.lua`
- Start a fresh shell, confirm the overlay loads without Bash startup errors, and run `repo-refresh-now` inside a clean repo under `~/projects/repos`.
- In Neovim, confirm yanks reach the Windows clipboard and pastes from the Windows clipboard reach Neovim.
- Confirm Windows Terminal uses JetBrainsMono Nerd Font and the Miasma color scheme after applying `windows-terminal/settings.json`.

## Troubleshooting

- **`stow` reports "existing target is not a symlink"**: Remove the conflicting file listed in the error, then re-run the stow command. Step 6 lists the expected cleanup targets.
- **Neovim clipboard not working**: Confirm `clip.exe` and `powershell.exe` are accessible from WSL (`which clip.exe`). If Windows interop is disabled, check `[interop]` in `/etc/wsl.conf`.
- **Bash overlay not loading**: Confirm the symlink exists (`test -L ~/.config/bash-overlays/20-repo-auto-refresh`) and that `dotfiles-arch` was stowed first so `enable_repo_auto_refresh` is defined.

## References

- `README.md` - WSL setup, stow order, and Windows Terminal application
- `DEVIATIONS.md` - intentional deviations from the shared baseline
- `AGENTS.md` - canonical repo-specific assistant context and maintainer checklist
- `CLAUDE.md` - thin Claude Code wrapper importing `AGENTS.md`

## Related Repos

Clone these locally if you plan to use `/synchronize` or compare this overlay against upstream references. The `/synchronize` skill expects reference repos under `~/projects/repos/references/`.

- `~/projects/repos/dotfiles/dotfiles-arch` - shared baseline required before this overlay
- `~/projects/repos/references/omarchy` - upstream Omarchy reference repo
- `~/projects/repos/references/omarchy-pkgs` - upstream package reference repo
- `~/projects/repos/references/miasma.nvim` - Miasma theme reference repo
- `~/projects/repos/references/windows-terminal` - Windows Terminal reference repo

## Credits

Adapted from [Omarchy](https://github.com/basecamp/omarchy). See [DEVIATIONS.md](DEVIATIONS.md) for intentional differences and overlay boundaries.

## License

[MIT](LICENSE)
