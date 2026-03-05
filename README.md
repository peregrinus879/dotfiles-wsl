# dotfiles-wsl

Personal dotfiles for WSL (Arch Linux), inspired by [Omarchy](https://github.com/basecamp/omarchy). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Stack

- **Shell**: Bash (modular config)
- **Terminal**: Windows Terminal + Miasma theme
- **Prompt**: Starship
- **Multiplexer**: Tmux (Ctrl+Space prefix)
- **Editor**: Neovim (LazyVim + Miasma)
- **Version Control**: Git + Lazygit
- **File Manager**: Yazi
- **System Monitor**: btop
- **System Info**: fastfetch
- **AI**: Claude Code (`cx`), OpenCode (`c`)

## Stow Packages

Each directory is a GNU Stow package that symlinks into `$HOME`:

```
bash/              Shell config (.bashrc, .inputrc, .config/bash/)
btop/              System monitor config + Miasma theme
editorconfig/      Editor formatting rules (.editorconfig)
fastfetch/         System info display config
git/               Git config (aliases, defaults)
nvim/              Neovim colorscheme (Miasma via LazyVim)
starship/          Prompt config
tmux/              Tmux config (keybindings, Miasma status bar)
windows-terminal/  Windows Terminal settings.json (applied manually, not stowed)
yazi/              File manager config + Miasma theme overrides
```

## Setup

### 0. Prerequisites (Windows)

Install the Nerd Font and WSL with Arch Linux from PowerShell:

```powershell
winget install DEVCOM.JetBrainsMonoNerdFont
wsl --install
wsl --install archlinux
```

### 1. Arch Linux Initial Setup

On first launch, Arch runs as root. Update the system and create your user:

```bash
pacman -Syu
useradd -m -G wheel -s /bin/bash <username>
passwd <username>
EDITOR=vim visudo  # uncomment: %wheel ALL=(ALL:ALL) ALL
```

Set the default user in `/etc/wsl.conf`:

```ini
[user]
default = <username>
```

Restart WSL from PowerShell: `wsl --shutdown`, then reopen.

### 2. Locale

Generate the `en_US.UTF-8` locale to avoid perl/stow warnings:

```bash
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
```

### 3. Packages

```bash
sudo pacman -S --needed bash-completion bat btop eza fastfetch fd fzf git \
  gum jq lazygit less neovim ripgrep starship stow tmux \
  ttf-jetbrains-mono-nerd yazi zoxide
```

### 4. Tools

LazyVim:

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

OpenCode:

```bash
curl -fsSL https://opencode.ai/install | bash
```

Claude Code:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### 5. Clone

```bash
git clone git@github.com:peregrinus879/dotfiles-wsl.git ~/dotfiles-wsl
```

### 6. Prepare

Remove existing files that would conflict with stow:

```bash
rm -f ~/.bashrc ~/.inputrc
rm -f ~/.config/nvim/lua/plugins/example.lua
rm -f ~/.config/nvim/lua/config/options.lua
rm -f ~/.config/nvim/lazyvim.json
```

### 7. Stow

```bash
cd ~/dotfiles-wsl

for pkg in bash btop editorconfig fastfetch git nvim starship tmux yazi; do
  stow -v -t ~ "$pkg"
done
```

### 8. Windows Terminal

Copy the contents of `windows-terminal/settings.json` into Windows Terminal's settings file:

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

### 9. Neovim Plugins

Open neovim to trigger plugin installation:

```bash
nvim
```

## Theme

All configs use the [Miasma](https://github.com/xero/miasma.nvim) color palette.

## Credits

Inspired by [Omarchy](https://github.com/basecamp/omarchy) by DHH.

## License

[MIT](LICENSE)
