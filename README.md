# EyrWSL

Self-contained Arch Linux dotfiles for WSL, adapted from [Omarchy](https://github.com/basecamp/omarchy), managed with [GNU Stow](https://www.gnu.org/software/stow/).

EyrWSL carries the full terminal baseline for Arch Linux running inside WSL, plus the WSL and Windows-specific pieces: Windows Terminal and clipboard integration. It keeps Omarchy's terminal tooling and general feel while dropping desktop-specific components that do not apply inside WSL.

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
- [`eyrwsl`](https://github.com/peregrinus879/eyrwsl) - Self-contained WSL Arch environment: terminal baseline plus Windows Terminal and clipboard integration

Related clones can live side by side under `~/Projects/eyrie/`, but EyrWSL installs and verifies independently.

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
- **Theme**: [Gruvbox](https://github.com/ellisonleao/gruvbox.nvim)

## Package Layout

Each top-level directory is a GNU Stow package that symlinks into `$HOME`, except `windows-terminal/`, which is deployed separately:

```text
bash/              Shell config (.bashrc, .inputrc, .config/bash/)
btop/              System monitor config (btop.conf, themes/gruvbox.theme)
editorconfig/      Editor formatting rules (.editorconfig)
fastfetch/         System info config (config.jsonc)
git/               Git config (config, ignore)
nvim/              Self-contained Neovim config (bootstrap, lock, LazyVim config and plugins)
starship/          Prompt config (starship.toml)
tmux/              Tmux config (tmux.conf)
yazi/              File manager config (yazi.toml)
windows-terminal/  Windows Terminal settings.json, deployed explicitly, not stowed
```

Key ownership rules:

- `nvim/` owns the full Neovim config, including the LazyVim bootstrap and lockfile plus `lua/config/options.lua` with the built-in WSL clipboard integration
- `nvim/` includes the vault plugin specs (`obsidian.lua`, `render-markdown.lua`); the vault is expected at `~/Projects/vault` (override with `OBSIDIAN_VAULT`)
- Bash supports additive machine overlays through `~/.config/bash-overlays/*`; the directory is optional and reserved for untracked machine-local additions
- Claude Code launches use the supported maximum effort, `--effort max`.
- Interactive Bash exports `OPENCODE_DISABLE_EXTERNAL_SKILLS=1` and `OPENCODE_ENABLE_EXA=1`; EyrAgents owns OpenCode runtime configuration
- EyrAgents owns shared OpenCode runtime and TUI configuration; its `system` theme selection inherits the Windows Terminal ANSI palette
- `windows-terminal/` stays Windows-side and intentionally tracks the full paste-ready `settings.json`; deployment is manual or backup-first through `make wt-push`

## Setup

### 1. Windows and WSL

EyrWSL targets current Windows 11 or a supported Windows 10 release with WSL2. Open PowerShell as Administrator, install Windows Terminal and the Nerd Font, and confirm Arch is listed online:

```powershell
winget install --id Microsoft.WindowsTerminal --exact --accept-package-agreements --accept-source-agreements
winget install --id DEVCOM.JetBrainsMonoNerdFont --exact --accept-package-agreements --accept-source-agreements
wsl --list --online
```

Windows Terminal uses the Windows-installed Nerd Font directly. WSL does not need a separate Linux font package for `tmux`, `nvim`, `yazi`, `starship`, or `fastfetch` icons to render correctly.

On a fresh Windows host, this command enables WSL and installs Arch instead of the default Ubuntu distribution:

```powershell
wsl --install -d archlinux
```

Restart Windows if prompted. If WSL is already enabled, update it before installing Arch with the same distro-specific command:

```powershell
wsl --update
wsl --install -d archlinux
```

After installation, require WSL2, make Arch the default distribution, and inspect the result:

```powershell
wsl --update
wsl --set-default-version 2
wsl --set-version archlinux 2
wsl --set-default archlinux
wsl --status
wsl --list --verbose
```

`wsl --list --verbose` must report `archlinux` at version `2` before continuing.

### 2. WSL Initial Setup

Launch Arch. The first shell runs as root. Set a root recovery password before creating the daily user, then update the system and install the bootstrap tools:

```bash
passwd
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

Open `nvim /etc/wsl.conf`, then set the default user and keep Windows interop enabled:

```ini
[user]
default = <username>

[interop]
enabled = true
```

Exit the root shell, then terminate only Arch from PowerShell so `/etc/wsl.conf` is applied without stopping unrelated distributions:

```powershell
wsl --terminate archlinux
wsl -d archlinux
```

Confirm the new shell opens as `<username>`, and run `sudo -v` before continuing.

### 3. Locale

Edit `/etc/locale.gen`, uncomment `en_US.UTF-8 UTF-8`, then generate the locale:

```bash
sudo nvim /etc/locale.gen
sudo locale-gen
sudo nvim /etc/locale.conf
```

Set the following value in `/etc/locale.conf`, then start a fresh WSL shell:

```ini
LANG=en_US.UTF-8
```

### 4. Prerequisites

Install the baseline packages required by these dotfiles:

```bash
sudo pacman -S --needed 7zip bash-completion bat btop curl diffutils eza fastfetch fd file findutils \
  fzf gcc git github-cli gum inetutils inotify-tools jq lazygit less lua make man-db man-pages \
  neovim nodejs openai-codex openssh opencode procps-ng python ripgrep rsync shellcheck starship \
  stow sudo tmux tree-sitter-cli unzip util-linux which yazi zoxide
```

All baseline packages come from official Arch repositories. `openai-codex` installs the official OpenAI terminal CLI as `codex`; `opencode` installs the OpenCode terminal CLI. The local documentation baseline uses `man-db` and `man-pages`, and 7-Zip enables Yazi archive previews and extraction. `nodejs` provides the runtime needed by EyrAgents verification; its workflow does not require `npm`. Windows interoperability handles host integration, so this terminal baseline does not add the desktop-oriented `xdg-utils`. This repo intentionally depends on no AUR packages and installs no AUR helper.

Verify the exact baseline; successful closure prints no output. Resolve every reported package before continuing:

```bash
pacman -T 7zip bash-completion bat btop curl diffutils eza fastfetch fd file findutils \
  fzf gcc git github-cli gum inetutils inotify-tools jq lazygit less lua make man-db man-pages \
  neovim nodejs openai-codex openssh opencode procps-ng python ripgrep rsync shellcheck starship \
  stow sudo tmux tree-sitter-cli unzip util-linux which yazi zoxide
```

For Yazi image, video, PDF, SVG, and extended archive previews, optionally install the official media helpers:

```bash
sudo pacman -S --needed ffmpeg imagemagick poppler resvg
```

These helpers are optional and are not required by `make verify`.

Claude Code and Herdr are not currently packaged in the official Arch repositories. Recheck each exact package name first:

```bash
pacman -Si claude-code
pacman -Si herdr
```

Proceed with the corresponding canonical user-level installer only while its probe reports `package not found`:

```bash
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://herdr.dev/install.sh | sh
```

Package ownership is Pacman-first. Before future reinstalls, recheck the official repositories; if `claude-code` or `herdr` becomes packaged, replace its standalone installation with the official package. Authentication and subscriptions are separate from installation; complete interactive sign-in only after the shell configuration is stowed.

If an existing shell resolves `opencode` to `~/.opencode/bin/opencode`, do not remove that binary while an OpenCode session is running. After the session ends, remove only `~/.opencode/bin/opencode`, start a fresh shell, run `hash -r`, and confirm `command -v opencode` prints `/usr/bin/opencode`. Leave the remaining `~/.opencode` content in place unless it is separately audited.

### 5. Clone

Create the parent directory and clone EyrWSL. EyrAgents is optional and recommended when this host will run Claude Code, Codex, or OpenCode with the shared agent harness:

```bash
mkdir -p ~/Projects/eyrie
git clone https://github.com/peregrinus879/eyrwsl.git ~/Projects/eyrie/eyrwsl
git clone https://github.com/peregrinus879/eyragents.git ~/Projects/eyrie/eyragents
```

Skip the EyrAgents clone for an EyrWSL-only installation. EyrWSL can be cloned elsewhere; adjust the commands below to match its location.

### 6. Neovim Ownership

The `nvim/` package includes the complete LazyVim bootstrap, static configuration, and generated plugin lockfile. Setup requires no separate Neovim configuration clone.

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
- EyrAgents was cloned beside EyrWSL if the shared AI agent harness is used
- `~/.config/git/config.local` exists with your local Git identity
- Any existing conflicting files were reviewed and moved or merged

Run the guarded preparation from the repository root:

```bash
cd ~/Projects/eyrie/eyrwsl
make clean
```

Preparation checks every endpoint before changing anything. It removes only symlinks that resolve into EyrWSL or the sibling EyrAgents OpenCode package. A regular file, foreign or broken symlink, special file, or path reached through an unrecognized repo-resolving parent aborts the entire run without partial removal. Compare and move or merge the reported conflict, then rerun `make clean`.

A fresh Arch user normally has a regular `~/.bashrc` from `/etc/skel`, so expect the first preparation run to report it. Compare any needed local content, move or merge it deliberately, and rerun `make clean`; the script never replaces it automatically.

The script keeps Git, Neovim, OpenCode, btop, and Yazi mutable or merge directories real. Other immutable config directories may use GNU Stow's normal tree-folding behavior. After preparation, use `make stow-all` when EyrAgents is present so its OpenCode configuration is linked.

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
stow -D -v -t ~ bash btop editorconfig fastfetch git nvim starship tmux yazi
```

### Dry Run

Preview what stow would do without making changes:

```bash
cd ~/Projects/eyrie/eyrwsl
stow -v -n -t ~ bash btop editorconfig fastfetch git nvim starship tmux yazi
```

### Re-stow

To update symlinks after the repo content changes (same clone path):

```bash
cd ~/Projects/eyrie/eyrwsl
stow -R -v -t ~ bash btop editorconfig fastfetch git nvim starship tmux yazi
```

To migrate from a different clone path, unstow from the old location first:

```bash
cd /old/clone/path
stow -D -v -t ~ bash btop editorconfig fastfetch git nvim starship tmux yazi
cd ~/Projects/eyrie/eyrwsl
stow -v -t ~ bash btop editorconfig fastfetch git nvim starship tmux yazi
```

If the old clone is no longer available, run the full cleanup in section 8 before stowing.

### 10. First Launch

Open Neovim once to install the revisions recorded in the tracked lockfile:

```bash
nvim
```

Run `:LazyHealth`, confirm Gruvbox loads, then exit and open Neovim again to verify the lock is stable. If the vault is synced to a different path, export `OBSIDIAN_VAULT` before launching Neovim; otherwise the vault workflow expects `~/Projects/vault`. Vault synchronization and the vault's `normalize.py` are user-owned data, not installed by this repo.

Start each installed AI terminal tool once and complete its own authentication flow:

```bash
claude
codex
opencode
```

Authentication failures do not indicate a dotfile deployment failure; resolve account access with the tool provider before testing `tdw` or `hdw`.

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

After stowing, run the automated gates from the repository root:

```bash
make verify
make lint
```

`make verify` fails closed unless the host is WSL2 with Windows interop, the configured command baseline is available, every Git-visible Stow source resolves to this repo, Git identity resolves without exposing its values, all owned Bash/Lua/TOML/JSON/JSONC and runtime configs validate, and retired theme content and paths remain absent. It then runs the deployment and verifier attack fixtures. `make lint` applies ShellCheck to the Bash package, scripts, and tests.

Complete these manual fresh-session checks:

- Confirm the core symlinks and local Git identity exist: `test -L ~/.bashrc && test -L ~/.config/starship.toml && test -L ~/.config/nvim/lua/config/options.lua && test -f ~/.config/git/config.local`
- Start a fresh shell and confirm Bash, Starship, and Tmux load without errors.
- Confirm `printenv OPENCODE_DISABLE_EXTERNAL_SKILLS` and `printenv OPENCODE_ENABLE_EXA` each print `1`.
- Confirm `type tdw` shows the tmux workspace function; from a project directory, `tdw cc` or `tdw oc` opens its session (`-c` continues that agent's last conversation; bare `tdw` re-attaches an existing session). Creating a session fails before changing tmux state when the selected agent is unavailable.
- Confirm `type hdw`, `type hdl`, `type hdlm`, and `type hsl` show the Herdr workspace functions. `hds` is intentionally unavailable because it requires Hunk.
- Confirm `pacman -Qo /usr/bin/codex /usr/bin/opencode` reports `openai-codex` and `opencode` ownership.
- Run `nvim` once and confirm plugins install successfully and Gruvbox loads.
- In Neovim, confirm yanks reach the Windows clipboard and pastes from the Windows clipboard reach Neovim.
- If the vault is synced to this machine, open a vault note and confirm obsidian.nvim loads (`<leader>oo` opens the note switcher).
- In OpenCode, run `/theme` and confirm `system` is selected so the TUI inherits Windows Terminal's Gruvbox ANSI palette.
- Confirm Windows Terminal uses JetBrainsMono Nerd Font and the Gruvbox color scheme after applying `windows-terminal/settings.json`.

## Troubleshooting

- **WSL or Arch does not start**: Confirm hardware virtualization is enabled in UEFI, run `wsl --update` from elevated PowerShell, and repeat `wsl --status` and `wsl --list --verbose`. Do not continue until `archlinux` launches under WSL2.
- **Preparation reports a conflict**: Compare the reported path, move or merge any needed content, then rerun `make clean`. The script never deletes regular files, foreign links, broken links, or special files.
- **Neovim clipboard not working**: Confirm `clip.exe` and `powershell.exe` are accessible from WSL (`which clip.exe`). If Windows interop is disabled, check `[interop]` in `/etc/wsl.conf`.
- **Obsidian image paste unavailable**: `:Obsidian paste_img` expects `wl-clipboard` or `xclip`, which this WSL baseline does not install. Save the image through Windows or the vault's own workflow, then link or embed it from the note.
- **OpenCode does not match Windows Terminal**: Select `system` with `/theme`. When EyrAgents is installed, confirm `~/.config/opencode/tui.json` resolves into its `opencode` package.

## Maintenance

A repo-root `Makefile` keeps the package list in one place and wraps the routine commands. Run targets from the repo root on the WSL machine:

- `make stow` / `make unstow` / `make dry-run` / `make restow` - the stow command sets from Setup
- `make stow-all` - stows EyrAgents' `opencode` package first, then all packages here
- `make verify` - delegate fail-closed host, deployment, identity, syntax, format, runtime, and theme-tombstone checks to `scripts/verify.sh`, then run every fixture suite
- `make clean` - WSL-only, all-or-nothing ownership preflight followed by managed-link removal and mutable-directory preparation
- `make test` - fake-home deployment, ownership, and verifier attack fixtures; the loop stops on the first failing suite
- `make lint` - ShellCheck over the bash package, `scripts/`, and `tests/`; `.shellcheckrc` disables the upstream-derived warnings so new issues stand out
- `make wt-diff` - diff the tracked Windows Terminal settings against the deployed Windows-side file (normalized with `jq`, since Windows Terminal rewrites key order)
- `make wt-pull` - WSL-only, validate and atomically copy deployed Windows Terminal settings into the repo for review
- `make wt-push` - WSL-only, validate, back up, and deploy tracked Windows Terminal settings

`nvim/.config/nvim/lazy-lock.json` is generated but tracked. Update it only through an intentional Lazy sync, review the pinned revision changes, verify a clean headless bootstrap, and commit the lockfile with the plugin-spec change that required it.

Periodically, review the local reference repos and official docs for upstream changes to owned packages, sync with `/omasync` or a manual comparison, and confirm every intentional difference is still documented in `DEVIATIONS.md`. Durable findings, known limitations, and deferred items live in [docs/maintenance.md](docs/maintenance.md).

## Related Repos

Upstream comparison runs through the `/omasync` skill, which carries the local reference clone paths. Upstream URLs and official docs live in [DEVIATIONS.md](DEVIATIONS.md) (Reference Sources).

## Credits

Adapted from [Omarchy](https://github.com/basecamp/omarchy). See [DEVIATIONS.md](DEVIATIONS.md) for intentional differences and boundary definitions.

## License

[MIT](LICENSE)
