#!/usr/bin/env bash
# Replace known LazyVim starter files with EyrWSL-managed links after backup.
set -euo pipefail

repo=$(realpath -e -- "$(dirname -- "${BASH_SOURCE[0]}")/..")
config_root="$HOME/.config/nvim"
static_paths=(
  init.lua
  lua/config/lazy.lua
  lua/config/autocmds.lua
  lua/config/keymaps.lua
  .neoconf.json
  stylua.toml
)
all_paths=("${static_paths[@]}" lazy-lock.json)

declare -A predecessor_hash=(
  [init.lua]=3b2d6e9976a515b7c8df08ed7c7f61a5751e9c08a6ff5579d621b87312c9e2c6
  [lua/config/lazy.lua]=14653a615b10689aa91915f45c284d07d5e7cb6c5f21fdbbf82c7664b9db4eb0
  [lua/config/autocmds.lua]=ccb2b3a99fe03698bdacaf41b98a48126c70fa38eaa1970e14e7309c876a9635
  [lua/config/keymaps.lua]=660a7d9a603a1b20b9ac13384ee21093f648646d8f4d575c52c5e5d9847f6764
  [.neoconf.json]=1819a5b64b71521f214b374bdb3b4dd7531a2b91b881c0803e0029811da7f3e4
  [stylua.toml]=59841fbcee7b707144c6a470e96e96e96062d7a59d2e45bac445984d863e1af2
)
declare -a migrate_paths=()

abort() {
  printf 'migrate-nvim-starter: %s\n' "$1" >&2
  exit 1
}

for tool in cmp cp date mkdir readlink realpath rm sha256sum stow uname; do
  command -v "$tool" >/dev/null || abort "required tool is missing: $tool"
done

kernel=$(uname -r)
[[ ${kernel,,} == *microsoft* ]] || abort "WSL is required for the live Neovim migration"
[[ -d $config_root && ! -L $config_root ]] || abort "$config_root must be a real directory"

for relative in "${all_paths[@]}"; do
  path="$config_root/$relative"
  source="$repo/nvim/.config/nvim/$relative"
  source_resolved=$(realpath -e -- "$source") || abort "tracked replacement is missing: $source"
  if [[ -e $path || -L $path ]]; then
    resolved=$(realpath -e -- "$path") || abort "$path is a broken symlink"
    [[ $resolved == "$source_resolved" ]] && continue
  fi

  parent="$config_root"
  IFS=/ read -r -a components <<<"$(dirname -- "$relative")"
  for component in "${components[@]}"; do
    [[ $component == . ]] && continue
    parent="$parent/$component"
    [[ ! -L $parent ]] || abort "$path resolves through a foreign symlinked parent: $parent"
  done

  if [[ -L $path ]]; then
    abort "$path is a foreign symlink to $(readlink -- "$path")"
  elif [[ -f $path ]]; then
    if [[ $relative != lazy-lock.json ]]; then
      read -r actual_hash _ < <(sha256sum -- "$path")
      [[ $actual_hash == "${predecessor_hash[$relative]}" ]] ||
        abort "$path differs from the pinned LazyVim starter; merge needed changes into $source, move the live file aside, then retry"
    fi
    migrate_paths+=("$relative")
  elif [[ -e $path ]]; then
    abort "$path is not a regular file or an EyrWSL-owned symlink"
  fi
done

backup=""
if (( ${#migrate_paths[@]} )); then
  backup="$HOME/.config/nvim.eyrwsl-backup-$(date +%Y%m%d-%H%M%S)"
  [[ ! -e $backup ]] || abort "backup already exists: $backup"
  mkdir -m 700 -- "$backup"

  for relative in "${migrate_paths[@]}"; do
    mkdir -p -- "$backup/$(dirname -- "$relative")"
    cp -p -- "$config_root/$relative" "$backup/$relative"
    cmp -s -- "$config_root/$relative" "$backup/$relative" || abort "backup verification failed: $relative"
    if [[ $relative != lazy-lock.json ]]; then
      read -r backup_hash _ < <(sha256sum -- "$backup/$relative")
      [[ $backup_hash == "${predecessor_hash[$relative]}" ]] || abort "backup provenance changed: $relative"
    fi
  done

  for relative in "${migrate_paths[@]}"; do
    rm -- "$config_root/$relative"
  done
fi

stow -v -t "$HOME" -d "$repo" nvim

if [[ -n $backup ]]; then
  printf 'backed up starter files: %s\n' "$backup"
  printf 'rollback instructions: %s/README.md (Neovim Ownership)\n' "$repo"
else
  printf 'Neovim starter migration already applied; refreshed nvim links\n'
fi
