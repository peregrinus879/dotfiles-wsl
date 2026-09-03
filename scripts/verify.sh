#!/usr/bin/env bash
# Verify the deployed WSL environment and every repository-owned config.
#
# Modes: full (the live host: command baseline, Windows interop, WSL2 kernel,
# deployment with real managed parents, no-reply Git identity, then every
# owned config), fixture (the same deployment, identity, and config checks
# against a fake repo and home, never the live home), and repo (owned configs
# only, runnable anywhere, including CI). Verifier tools fail closed in every
# mode; the command baseline and interop commands are host facts checked in
# full mode only.
set -euo pipefail

script_repo=$(realpath -e -- "$(dirname -- "${BASH_SOURCE[0]}")/..")
mode=${VERIFY_MODE:-full}
repo=${VERIFY_REPO:-$script_repo}
verify_home=${VERIFY_HOME:-$HOME}

[[ -n ${VERIFY_PACKAGES:-} ]] || { printf 'FAIL: VERIFY_PACKAGES is required\n' >&2; exit 1; }
repo=$(realpath -e -- "$repo")
verify_home=$(realpath -e -- "$verify_home")
read -r -a packages <<<"$VERIFY_PACKAGES"
(( ${#packages[@]} )) || { printf 'FAIL: package list is empty\n' >&2; exit 1; }

case $mode in
  full)
    live_home=$(realpath -e -- "$HOME")
    [[ $repo == "$script_repo" && $verify_home == "$live_home" ]] || {
      printf 'FAIL: full mode must use the live repository and HOME\n' >&2
      exit 1
    }
    ;;
  repo) ;;
  fixture)
    [[ -n ${VERIFY_REPO:-} && -n ${VERIFY_HOME:-} && -n ${VERIFY_KERNEL_RELEASE:-} ]] || {
      printf 'FAIL: fixture mode requires VERIFY_REPO, VERIFY_HOME, and VERIFY_KERNEL_RELEASE\n' >&2
      exit 1
    }
    login_home=$(getent passwd "$(id -un)" | cut -d: -f6)
    [[ -n $login_home && $verify_home != "$(realpath -m -- "$login_home")" ]] || {
      printf 'FAIL: fixture mode must not target the live HOME\n' >&2
      exit 1
    }
    ;;
  *)
    printf 'FAIL: unknown VERIFY_MODE: %s\n' "$mode" >&2
    exit 1
    ;;
esac

fail=0

ok() {
  printf 'ok:   %s\n' "$1"
}

problem() {
  printf 'FAIL: %s\n' "$1" >&2
  fail=1
}

# Tools this script runs itself; a missing one fails every mode.
verifier_tools=(bash cmp diff fastfetch find git jq luac python3 readlink realpath tmux)
[[ -n ${VERIFY_EXTRA_REQUIRED_TOOL:-} ]] && verifier_tools+=("$VERIFY_EXTRA_REQUIRED_TOOL")
for tool in "${verifier_tools[@]}"; do
  command -v "$tool" >/dev/null || {
    printf 'FAIL: required verifier is missing: %s\n' "$tool" >&2
    exit 1
  }
done
ok "verifier tools are available"

if [[ $mode == full ]]; then
  baseline_tools=(
    7z bat btop claude codex curl eza fd file fzf gcc gh gum herdr hostname inotifywait
    lazygit less lua make man nvim pgrep opencode rg rsync shellcheck ssh starship stow sudo
    tree-sitter unzip which yazi zoxide
  )
  for tool in "${baseline_tools[@]}"; do
    command -v "$tool" >/dev/null || {
      printf 'FAIL: required tool is missing: %s\n' "$tool" >&2
      exit 1
    }
  done
  ok "required command baseline is available"
  for tool in clip.exe powershell.exe; do
    if command -v "$tool" >/dev/null; then
      ok "Windows interop command is available: $tool"
    else
      problem "Windows interop command is missing: $tool"
    fi
  done
fi

if [[ $mode != repo ]]; then
  if [[ $mode == fixture ]]; then
    kernel=$VERIFY_KERNEL_RELEASE
  else
    kernel=$(uname -r)
  fi
  kernel_lower=${kernel,,}
  if [[ $kernel_lower == *microsoft* && $kernel_lower == *wsl2* ]]; then
    ok "WSL2 kernel marker: $kernel"
  else
    problem "WSL2 kernel marker is required, got: $kernel"
  fi
fi

if [[ $mode != repo ]]; then
  deployed_sources=0
  while IFS= read -r source; do
    [[ -n $source ]] || continue
    ((deployed_sources += 1))
    source_path="$repo/$source"
    target="$verify_home/${source#*/}"
    if [[ ! -e $source_path && ! -L $source_path ]]; then
      problem "Git-visible Stow source is missing: $source"
    elif [[ $(readlink -f -- "$target") == $(readlink -f -- "$source_path") ]]; then
      ok "$target resolves into the repo"
    else
      problem "$target does not resolve to $source_path"
    fi
  done < <(git -C "$repo" ls-files --cached --others --exclude-standard -- "${packages[@]}")
  (( deployed_sources > 0 )) || problem "Git-visible Stow source set is empty"

  # Every managed parent must be a real directory: a folded one means a
  # deployment made with folding that make restow has not replaced.
  while IFS= read -r rel; do
    target="$verify_home/$rel"
    if [[ -d $target && ! -L $target ]]; then
      ok "$target is a real directory"
    else
      problem "managed directory is folded or missing: $target"
    fi
  done < <(git -C "$repo" ls-files --cached --others --exclude-standard -- "${packages[@]}" |
    while IFS= read -r source; do rel=${source#*/}
      while [[ $rel == */* ]]; do rel=${rel%/*}; printf '%s\n' "$rel"; done; done | sort -u)

  # The values are never printed: the email must be a GitHub no-reply address.
  name=$(HOME="$verify_home" git config --includes --file "$verify_home/.config/git/config" --get user.name 2>/dev/null || true)
  email=$(HOME="$verify_home" git config --includes --file "$verify_home/.config/git/config" --get user.email 2>/dev/null || true)
  if [[ -n ${name//[[:space:]]/} && $email == *@users.noreply.github.com ]]; then
    ok "Git identity resolves to a name and a GitHub no-reply address"
  else
    problem "Git identity must resolve to a name and a GitHub no-reply address"
  fi
fi

while IFS= read -r file; do
  if bash -n "$file"; then
    ok "bash -n ${file#"$repo/"}"
  else
    problem "Bash syntax failed: ${file#"$repo/"}"
  fi
done < <(find "$repo/bash" -type f \( -name '.bashrc' -o -path '*/.config/bash/*' \) ! -name '.inputrc' -print)

while IFS= read -r -d '' file; do
  if luac -p "$file" >/dev/null; then
    ok "luac -p ${file#"$repo/"}"
  else
    problem "Lua syntax failed: ${file#"$repo/"}"
  fi
done < <(find "$repo/nvim" -type f -name '*.lua' -print0)

toml_files=(
  starship/.config/starship.toml
  yazi/.config/yazi/yazi.toml
  nvim/.config/nvim/stylua.toml
)
for relative in "${toml_files[@]}"; do
  if python3 -c 'import sys,tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$repo/$relative" 2>/dev/null; then
    ok "$relative parses as TOML"
  else
    problem "$relative is not valid TOML"
  fi
done

bootstrap_files=(
  nvim/.config/nvim/init.lua
  nvim/.config/nvim/lua/config/lazy.lua
  nvim/.config/nvim/lua/config/autocmds.lua
  nvim/.config/nvim/lua/config/keymaps.lua
  nvim/.config/nvim/.neoconf.json
  nvim/.config/nvim/stylua.toml
  nvim/.config/nvim/lazy-lock.json
)
for relative in "${bootstrap_files[@]}"; do
  if [[ -f $repo/$relative ]]; then
    ok "$relative is present"
  else
    problem "missing Neovim bootstrap file: $relative"
  fi
done

json_files=(
  nvim/.config/nvim/.neoconf.json
  nvim/.config/nvim/lazy-lock.json
  nvim/.config/nvim/lazyvim.json
  windows-terminal/settings.json
)
for relative in "${json_files[@]}"; do
  if jq -e 'type == "object"' "$repo/$relative" >/dev/null 2>&1; then
    ok "$relative parses as a JSON object"
  else
    problem "$relative is not a valid JSON object"
  fi
done

if jq -e 'type == "object" and length > 0 and has("LazyVim") and has("gruvbox.nvim")' \
  "$repo/nvim/.config/nvim/lazy-lock.json" >/dev/null 2>&1; then
  ok "lazy-lock.json pins LazyVim and Gruvbox"
else
  problem "lazy-lock.json is missing required pins"
fi

if jq -e '
  .defaultProfile == "archlinux"
  and .disabledProfileSources == ["Windows.Terminal.Wsl"]
  and ([.profiles.list[] | select(.name == "archlinux")] | length == 0)
  and .profiles.defaults.colorScheme == "Gruvbox"
  and .profiles.defaults.font.face == "JetBrainsMono Nerd Font"
  and .profiles.defaults.font.size == 9
  and .schemes[0].name == "Gruvbox"
' "$repo/windows-terminal/settings.json" >/dev/null 2>&1; then
  ok "Windows Terminal selects the dynamic Arch profile and Omarchy terminal appearance"
else
  problem "Windows Terminal profile or appearance contract is invalid"
fi

if fastfetch --config "$repo/fastfetch/.config/fastfetch/config.jsonc" --format json >/dev/null 2>&1; then
  ok "Fastfetch config parses and runs"
else
  problem "Fastfetch config failed runtime validation"
fi

if HOME="$verify_home" XDG_CONFIG_HOME="$verify_home/.config" \
  git config --includes --file "$repo/git/.config/git/config" --list >/dev/null 2>&1; then
  ok "Git config parses"
else
  problem "Git config failed to parse"
fi

tmux_socket="eyrwsl-verify-$$"
if tmux -L "$tmux_socket" -f /dev/null new-session -d -s verify >/dev/null 2>&1 &&
  tmux -L "$tmux_socket" source-file -n "$repo/tmux/.config/tmux/tmux.conf" >/dev/null 2>&1; then
  ok "tmux config parses"
else
  problem "tmux config failed to parse"
fi
tmux -L "$tmux_socket" kill-server >/dev/null 2>&1 || true

if [[ -f $repo/btop/.config/btop/btop.conf ]] &&
  [[ $(<"$repo/btop/.config/btop/btop.conf") == *'color_theme = "gruvbox"'* ]]; then
  ok "btop selects Gruvbox"
else
  problem "btop does not select Gruvbox"
fi

exit "$fail"
