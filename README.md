# EyrWSL

Self-contained Arch Linux dotfiles for WSL, adapted from [Omarchy](https://github.com/basecamp/omarchy), managed with [GNU Stow](https://www.gnu.org/software/stow/).

EyrWSL carries the full terminal baseline for Arch Linux running inside WSL, plus the WSL and Windows-specific pieces: Windows Terminal, clipboard integration, and OpenCode theme availability. It keeps Omarchy's terminal tooling and general feel while dropping desktop-specific components that do not apply inside WSL.

Eyrie is the shared project habitat, reflected locally in `~/Projects/eyrie/`. `Eyr` is its shortened family prefix, used by EyrAgents, EyrArcHy, and EyrWSL.

## Repo Family

Derivation model for this repo family:

```text
AI agent harness                → EyrAgents
Omarchy + personal deviations   → EyrArcHy
Omarchy + WSL deviations        → EyrWSL
```

- [`eyragents`](https://github.com/peregrinus879/eyragents) - AI agent harness: Claude Code, Codex, and OpenCode settings, shared guidance, and commit workflow
- [`eyrarchy`](https://github.com/peregrinus879/eyrarchy) - Personal Omarchy customizations: Bash overrides, Hyprland bindings, Neovim plugins, and Yazi
- [`eyrwsl`](https://github.com/peregrinus879/eyrwsl) - Self-contained WSL Arch environment: terminal baseline plus Windows Terminal, clipboard integration, and OpenCode theme

Local clones live side by side under `~/Projects/eyrie/`.

## Stack

- **Shell**: [Bash](https://www.gnu.org/software/bash/)
- **Prompt**: [Starship](https://github.com/starship/starship)
- **Terminal Workspaces**: [Tmux](https://github.com/tmux/tmux), [Herdr](https://herdr.dev/)
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

Each top-level directory is a GNU Stow package that symlinks into `$HOME`, except `windows-terminal/`, which is deployed separately:

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
windows-terminal/  Windows Terminal settings.json, deployed explicitly, not stowed
```

Key ownership rules:

- `nvim/` owns the full Neovim config, including `lua/config/options.lua` with the built-in WSL clipboard integration
- `nvim/` includes the vault plugin specs (`obsidian.lua`, `render-markdown.lua`); the vault is expected at `~/Projects/vault` (override with `OBSIDIAN_VAULT`)
- Bash supports additive machine overlays through `~/.config/bash-overlays/*`; the directory is optional and reserved for untracked machine-local additions
- Claude Code launches use the supported maximum effort, `--effort max`. `tdw` and `hdw` are byte-identical twins with EyrArcHy.
- Interactive Bash exports `OPENCODE_DISABLE_EXTERNAL_SKILLS=1` and `OPENCODE_ENABLE_EXA=1`; EyrAgents owns OpenCode runtime configuration
- EyrAgents keeps ownership of shared OpenCode runtime config; `opencode-wsl/` only adds Miasma theme availability without forcing the selected theme
- `~/.config/opencode/` and `~/.config/opencode/themes/` must be real merge directories so EyrAgents and `opencode-wsl` can both link files inside them
- `windows-terminal/` stays Windows-side and intentionally tracks the full paste-ready `settings.json`; deployment is manual or backup-first through `make wt-push`
- repo-root `.claude/settings.json` and `opencode.json` are per-tool project allowlists for this repo's verification make targets (`verify`, `lint`); they are not stowed

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
sudo pacman -S --needed 7zip bash-completion bat btop curl diffutils eza fastfetch fd file findutils \
  fzf gcc git github-cli gum inetutils inotify-tools jq lazygit less lua make man-db man-pages \
  neovim nodejs openai-codex openssh opencode procps-ng python ripgrep rsync shellcheck starship \
  stow sudo tmux tree-sitter-cli unzip util-linux which yazi zoxide
```

All baseline packages come from official Arch repositories. `openai-codex` installs the official OpenAI terminal CLI as `codex`; `opencode` installs the OpenCode terminal CLI. The local documentation baseline uses `man-db` and `man-pages`, and 7-Zip enables Yazi archive previews and extraction. This repo intentionally depends on no AUR packages and installs no AUR helper.

Claude Code and Herdr are not currently packaged in the official Arch repositories. Install them from their canonical user-level installers:

```bash
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://herdr.dev/install.sh | sh
```

If an existing shell resolves `opencode` to `~/.opencode/bin/opencode`, do not remove that binary while an OpenCode session is running. After the session ends, remove only `~/.opencode/bin/opencode`, start a fresh shell, run `hash -r`, and confirm `command -v opencode` prints `/usr/bin/opencode`. Leave the remaining `~/.opencode` content in place unless it is separately audited.

### 5. Clone

Recommended local layout for this repo family:

```text
~/Projects/eyrie/eyrwsl
```

Stow can work from any clone location, but the related docs and cross-repo maintenance workflows assume this layout.

```bash
git clone https://github.com/peregrinus879/eyrwsl.git ~/Projects/eyrie/eyrwsl
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
- EyrWSL was cloned locally
- LazyVim starter was cloned into `~/.config/nvim`
- `~/.config/git/config.local` exists with your local Git identity
- EyrAgents OpenCode config is already stowed if you use OpenCode on this WSL install
- Any existing conflicting files were reviewed and moved or merged

Run the guarded preparation from the repository root:

```bash
cd ~/Projects/eyrie/eyrwsl
make clean
```

Preparation checks every endpoint before changing anything. It removes only symlinks that resolve into EyrWSL or the sibling EyrAgents OpenCode package. A regular file, foreign or broken symlink, special file, or path reached through an unrecognized repo-resolving parent aborts the entire run without partial removal. Compare and move or merge the reported conflict, then rerun `make clean`.

The script keeps Git, Neovim, OpenCode, btop, and Yazi mutable or merge directories real. Other immutable config directories may use GNU Stow's normal tree-folding behavior. After preparation, use `make stow-all` when EyrAgents is present so its OpenCode config is linked before EyrWSL adds the theme.

### 9. Stow

With the recommended sibling EyrAgents clone, restore its OpenCode package first and then all EyrWSL packages:

```bash
cd ~/Projects/eyrie/eyrwsl
make stow-all
```

For an EyrWSL-only installation without EyrAgents, run `make stow` instead.

Start a new terminal session, or run `source ~/.bashrc`, for the shell config to take effect.

### Unstow

```bash
cd ~/Projects/eyrie/eyrwsl
stow -D -v -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
```

### Dry Run

Preview what stow would do without making changes:

```bash
cd ~/Projects/eyrie/eyrwsl
stow -v -n -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
```

### Re-stow

To update symlinks after the repo content changes (same clone path):

```bash
cd ~/Projects/eyrie/eyrwsl
stow -R -v -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
```

To migrate from a different clone path, unstow from the old location first:

```bash
cd /old/clone/path
stow -D -v -t ~ bash btop editorconfig fastfetch git nvim opencode-wsl starship tmux yazi
cd ~/Projects/eyrie/eyrwsl
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

From WSL, the explicit deployment workflow resolves the active Windows account through PowerShell, validates both JSON files, creates a timestamped backup beside the deployed file, and replaces it in the same directory:

```bash
cd ~/Projects/eyrie/eyrwsl
make wt-diff
make wt-push
make wt-diff
```

If rollback is needed, copy the reported `settings.json.backup-<timestamp>` over the deployed `settings.json`. Backups remain until you delete them manually. `make wt-pull` atomically copies valid deployed JSON into the repository for review; it never commits the result. Set `WT_SETTINGS` only when Windows Terminal uses a nonstandard settings path. If deployed settings are missing or invalid, launch Windows Terminal once or restore/copy a valid file manually before using the automated workflow.

## Verify

After stowing:

- Confirm the core symlinks and local Git identity exist: `test -L ~/.bashrc && test -L ~/.config/starship.toml && test -L ~/.config/nvim/lua/config/options.lua && test -f ~/.config/git/config.local`
- Confirm the OpenCode theme symlink exists: `test -L ~/.config/opencode/themes/miasma.json`
- Start a fresh shell and confirm Bash, Starship, and Tmux load without errors.
- Confirm `printenv OPENCODE_DISABLE_EXTERNAL_SKILLS` and `printenv OPENCODE_ENABLE_EXA` each print `1`.
- Confirm `type tdw` shows the tmux workspace function; from a project directory, `tdw cc` or `tdw oc` opens its session (`-c` continues that agent's last conversation; bare `tdw` re-attaches an existing session). Creating a session fails before changing tmux state when the selected agent is unavailable.
- Confirm `type hdw`, `type hdl`, `type hdlm`, and `type hsl` show the Herdr workspace functions. `hds` is intentionally unavailable because it requires Hunk.
- Confirm `pacman -Qo /usr/bin/codex /usr/bin/opencode` reports `openai-codex` and `opencode` ownership.
- Run `nvim` once and confirm plugins install successfully and Miasma loads.
- In Neovim, confirm yanks reach the Windows clipboard and pastes from the Windows clipboard reach Neovim.
- If the vault is synced to this machine, open a vault note and confirm obsidian.nvim loads (`<leader>oo` opens the note switcher).
- In OpenCode, run `/theme` and confirm `miasma` is available. Select it if OpenCode is still using the `system` theme.
- Confirm Windows Terminal uses JetBrainsMono Nerd Font and the Miasma color scheme after applying `windows-terminal/settings.json`.

## Troubleshooting

- **Preparation reports a conflict**: Compare the reported path, move or merge any needed content, then rerun `make clean`. The script never deletes regular files, foreign links, broken links, or special files.
- **Neovim clipboard not working**: Confirm `clip.exe` and `powershell.exe` are accessible from WSL (`which clip.exe`). If Windows interop is disabled, check `[interop]` in `/etc/wsl.conf`.
- **OpenCode Miasma not listed**: Confirm `~/.config/opencode/themes/miasma.json` is a symlink to `opencode-wsl/.config/opencode/themes/miasma.json`. If `~/.config/opencode` or `~/.config/opencode/themes` is still a directory symlink to another dotfiles package, repeat the merge directory prep in section 8, then re-run the stow command.

## Maintenance

A repo-root `Makefile` keeps the package list in one place and wraps the routine commands. Run targets from the repo root on the WSL machine:

- `make stow` / `make unstow` / `make dry-run` / `make restow` - the stow command sets from Setup
- `make stow-all` - stows EyrAgents' `opencode` package first, then all packages here
- `make verify` - every Git-visible Stow source resolves to its deployed target, the local Git identity exists, Bash and Lua syntax pass, `yazi.toml` parses, every twin matches EyrArcHy, and guarded-preparation fixtures pass; required verifier tools fail closed
- `make clean` - WSL-only, all-or-nothing ownership preflight followed by managed-link removal and mutable-directory preparation
- `make test` - fake-home attack and ownership fixtures for guarded preparation
- `make lint` - ShellCheck over the bash package and `scripts/`; `.shellcheckrc` disables the upstream-derived warnings so new issues stand out
- `make wt-diff` - diff the tracked Windows Terminal settings against the deployed Windows-side file (normalized with `jq`, since Windows Terminal rewrites key order)
- `make wt-pull` - WSL-only, validate and atomically copy deployed Windows Terminal settings into the repo for review
- `make wt-push` - WSL-only, validate, back up, and deploy tracked Windows Terminal settings

Periodically, review the local reference repos and official docs for upstream changes to owned packages, sync with `/synchronize` or a manual comparison, and confirm every intentional difference is still documented in `DEVIATIONS.md`.

## Related Repos

Upstream comparison runs through the `/synchronize` skill, which carries the local reference clone paths. Upstream URLs and official docs live in [DEVIATIONS.md](DEVIATIONS.md) (Reference Sources).

## Credits

Adapted from [Omarchy](https://github.com/basecamp/omarchy). See [DEVIATIONS.md](DEVIATIONS.md) for intentional differences and boundary definitions.

## License

[MIT](LICENSE)
