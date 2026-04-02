# dotfiles-wsl

WSL overlay dotfiles for making an Arch Linux WSL environment look and feel like Omarchy, managed with [GNU Stow](https://www.gnu.org/software/stow/).

This repo is applied on top of `dotfiles-arch`. It owns only the WSL and Windows-specific pieces needed to complete the Omarchy-like setup on Arch Linux running inside WSL.

## Stack

- **Base Layer**: `dotfiles-arch`
- **Terminal**: [Windows Terminal](https://github.com/microsoft/terminal)
- **Editor Overlay**: [Neovim](https://github.com/neovim/neovim) WSL clipboard integration
- **Theme**: [Miasma](https://github.com/xero/miasma.nvim)

## Stow Packages

Each directory is a GNU Stow package or a manually applied config:

```text
nvim-wsl/          WSL-specific Neovim options.lua overlay
windows-terminal/  Windows Terminal settings.json, applied manually, not stowed
```

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

### 4. Apply dotfiles-arch First

Before using this repo, complete the full `dotfiles-arch` setup first:

- install the baseline packages
- clone the LazyVim starter into `~/.config/nvim`
- create `~/.config/git/config.local`
- clone `dotfiles-arch`
- run the Arch baseline stow command without `nvim-arch`

On WSL, apply the shared baseline packages from `dotfiles-arch` without `nvim-arch`:

```bash
cd ~/path/to/dotfiles-arch
stow -v -t ~ bash btop editorconfig fastfetch git nvim starship tmux yazi
```

This repo assumes the shared shell, tmux, git, fastfetch, btop, Yazi, and shared Neovim config already come from `dotfiles-arch`.

### 5. Clone

```bash
git clone https://github.com/peregrinus879/dotfiles-wsl.git ~/path/to/dotfiles-wsl
```

Or with SSH:

```bash
git clone git@github.com:peregrinus879/dotfiles-wsl.git ~/path/to/dotfiles-wsl
```

### 6. Stow

Checklist before stowing the overlay:

- `dotfiles-arch` prerequisites and shared baseline stow are already complete
- `~/.config/nvim` exists as a real LazyVim starter directory
- `nvim-arch` is not currently stowed on this WSL machine
- Any existing conflicting WSL overlay file was removed

If `nvim-arch` was ever stowed on this WSL machine, unstow it first from the `dotfiles-arch` repo:

```bash
cd ~/path/to/dotfiles-arch
stow -D -v -t ~ nvim-arch
```

Remove any existing conflicting WSL overlay file:

```bash
rm -f ~/.config/nvim/lua/config/options.lua
```

Then stow the WSL overlay:

```bash
cd ~/path/to/dotfiles-wsl
stow -v -t ~ nvim-wsl
```

### Unstow

```bash
cd ~/path/to/dotfiles-wsl
stow -D -v -t ~ nvim-wsl
```

### Dry Run

Preview what stow would do without making changes:

```bash
cd ~/path/to/dotfiles-wsl
stow -v -n -t ~ nvim-wsl
```

## Windows Terminal

Open Windows Terminal settings JSON with `Ctrl+Shift+,` and replace the contents with `windows-terminal/settings.json`.

Alternatively, edit the file directly at:

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

## Private Git Identity

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

## References

- `README.md` - WSL setup, stow order, and Windows Terminal application
- `APPROACH.md` - WSL-specific deviations from the shared baseline
- `CLAUDE.md` - repo-specific assistant context

## Related Repos

- `~/projects/repos/dotfiles/dotfiles-arch` - shared baseline required before this overlay
- `~/projects/repos/references/omarchy` - upstream Omarchy reference repo
- `~/projects/repos/references/omarchy-pkgs` - upstream package reference repo
- `~/projects/repos/references/miasma.nvim` - Miasma theme reference repo
- `~/projects/repos/references/windows-terminal` - Windows Terminal reference repo

## Credits

Adapted from [Omarchy](https://github.com/basecamp/omarchy). See [APPROACH.md](APPROACH.md) for overlay rationale and deviations.

## License

[MIT](LICENSE)
