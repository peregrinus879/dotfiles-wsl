# dotfiles-wsl

Personal dotfiles for WSL (Arch Linux), adapted from [Omarchy](https://github.com/basecamp/omarchy). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Stack

- **Shell**: [Bash](https://www.gnu.org/software/bash/)
- **Terminal**: [Windows Terminal](https://github.com/microsoft/terminal)
- **Prompt**: [Starship](https://github.com/starship/starship)
- **Multiplexer**: [Tmux](https://github.com/tmux/tmux)
- **Editor**: [Neovim](https://github.com/neovim/neovim) ([LazyVim](https://github.com/LazyVim/LazyVim))
- **Version Control**: [Git](https://git-scm.com/) + [LazyGit](https://github.com/jesseduffield/lazygit)
- **File Manager**: [Yazi](https://github.com/sxyazi/yazi)
- **System Monitor**: [btop](https://github.com/aristocratos/btop)
- **System Info**: [fastfetch](https://github.com/fastfetch-cli/fastfetch)
- **AI**: [Claude Code](https://github.com/anthropics/claude-code), [OpenCode](https://github.com/anomalyco/opencode)
- **Theme**: [Miasma](https://github.com/xero/miasma.nvim)

## Stow Packages

Each directory is a GNU Stow package that symlinks into `$HOME`:

```
bash/              Shell config (.bashrc, .inputrc, .config/bash/)
btop/              System monitor config (btop.conf, themes/miasma.theme)
editorconfig/      Editor formatting rules (.editorconfig)
fastfetch/         System info config (config.jsonc)
git/               Git config (config)
nvim/              Neovim config (lazyvim.json, lua/config/, lua/plugins/, plugin/after/)
starship/          Prompt config (starship.toml)
tmux/              Tmux config (tmux.conf)
windows-terminal/  Windows Terminal config (settings.json, not stowed)
yazi/              File manager config (yazi.toml, theme.toml)
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
pacman -S --needed git neovim sudo
useradd -m -G wheel -s /bin/bash <username>
passwd <username>
EDITOR=nvim visudo  # uncomment: %wheel ALL=(ALL:ALL) ALL
```

Set the default user and enable Windows interop in `/etc/wsl.conf`:

```ini
[user]
default = <username>

[interop]
enabled = true
```

Restart WSL from PowerShell: `wsl --shutdown`, then reopen.

### 2. Locale

Generate the `en_US.UTF-8` locale to avoid perl/stow warnings:

```bash
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
```

### 3. SSH Key

Generate an SSH key and add it to GitHub:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Copy the output and add it at [github.com/settings/ssh/new](https://github.com/settings/ssh/new).

Test the connection:

```bash
ssh -T git@github.com
```

Authenticate the GitHub CLI using your existing SSH setup:

```bash
gh auth login -h github.com -p ssh
```

### 4. Packages

Install required packages:

```bash
sudo pacman -S --needed bash-completion bat btop eza fastfetch fd fzf gum github-cli \
  jq lazygit less ripgrep starship stow tmux ttf-jetbrains-mono-nerd yazi zoxide
```

### 5. Tools

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

### 6. Clone

Clone the dotfiles repo:

```bash
git clone https://github.com/peregrinus879/dotfiles-wsl.git ~/path/to/dotfiles-wsl
```

Or, if you set up SSH in step 3:

```bash
git clone git@github.com:peregrinus879/dotfiles-wsl.git ~/path/to/dotfiles-wsl
```

Optionally, clone upstream reference repos in a sibling `upstream/` directory for customizing configs:

```bash
mkdir -p ~/path/to/upstream
git clone https://github.com/basecamp/omarchy.git ~/path/to/upstream/omarchy
git clone https://github.com/omacom-io/omarchy-pkgs.git ~/path/to/upstream/omarchy-pkgs
git clone https://github.com/xero/miasma.nvim.git ~/path/to/upstream/miasma.nvim
```

### 7. Prepare

Remove existing files that would conflict with stow:

```bash
rm -f ~/.bashrc ~/.inputrc
rm -f ~/.config/nvim/lazyvim.json
rm -f ~/.config/nvim/lua/config/options.lua
rm -f ~/.config/nvim/lua/plugins/example.lua
```

### 8. Stow

Create symlinks for all packages:

```bash
cd ~/path/to/dotfiles-wsl

for pkg in bash btop editorconfig fastfetch git nvim starship tmux yazi; do
  stow -v -t ~ "$pkg"
done
```

### Unstow

```bash
cd ~/path/to/dotfiles-wsl
for pkg in bash btop editorconfig fastfetch git nvim starship tmux yazi; do
  stow -D -v -t ~ "$pkg"
done
```

### Dry Run

Preview what stow would do without making changes:

```bash
cd ~/path/to/dotfiles-wsl
for pkg in bash btop editorconfig fastfetch git nvim starship tmux yazi; do
  stow -v -n -t ~ "$pkg"
done
```

### 9. Windows Terminal

Open Windows Terminal settings JSON with `Ctrl+Shift+,` and replace the contents with `windows-terminal/settings.json`.

Alternatively, edit the file directly at:

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

### 10. Neovim Plugins

Open neovim to trigger plugin installation:

```bash
nvim
```

## Credits

Adapted from [Omarchy](https://github.com/basecamp/omarchy). See [APPROACH.md](APPROACH.md) for methodology and deviations.

## License

[MIT](LICENSE)
