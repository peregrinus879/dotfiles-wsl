#!/usr/bin/env bash
# Prepare EyrWSL and EyrAgents OpenCode endpoints without deleting user files.
set -euo pipefail

repo=$(realpath -e -- "$(dirname -- "${BASH_SOURCE[0]}")/..")
ai_repo=$(realpath -m -- "${EYRAGENTS_REPO:-$repo/../eyragents}")
packages=(bash btop editorconfig fastfetch git nvim starship tmux yazi)

declare -a remove_links=()
declare -a create_dirs=()
declare -a replaced_dirs=()

abort() {
  printf 'prepare-stow: %s\n' "$1" >&2
  exit 1
}

kernel=$(uname -r)
[[ ${kernel,,} == *microsoft* ]] || abort "WSL is required for deployment preparation"

is_managed_target() {
  local target=$1
  [[ $target == "$repo"/* || $target == "$ai_repo/opencode"/* ]]
}

queue_unique() {
  local array_name=$1 value=$2 existing
  local -n array=$array_name
  for existing in "${array[@]}"; do
    [[ $existing == "$value" ]] && return
  done
  array+=("$value")
}

under_replaced_dir() {
  local path=$1 dir
  for dir in "${replaced_dirs[@]}"; do
    [[ $path == "$dir" || $path == "$dir/"* ]] && return 0
  done
  return 1
}

queue_managed_link() {
  local path=$1 target
  target=$(realpath -e -- "$path") || abort "$path is a broken symlink; refusing to remove it"
  is_managed_target "$target" || abort "$path is an unmanaged symlink to $(readlink -- "$path")"
  queue_unique remove_links "$path"
}

prepare_real_dir() {
  local path=$1
  if under_replaced_dir "$path"; then
    queue_unique create_dirs "$path"
    queue_unique replaced_dirs "$path"
  elif [[ -L $path ]]; then
    queue_managed_link "$path"
    queue_unique create_dirs "$path"
    queue_unique replaced_dirs "$path"
  elif [[ -e $path && ! -d $path ]]; then
    abort "$path must be a real directory"
  else
    queue_unique create_dirs "$path"
  fi
}

prepare_fold_dir() {
  local path=$1
  under_replaced_dir "$path" && return
  if [[ -L $path ]]; then
    queue_managed_link "$path"
    queue_unique replaced_dirs "$path"
  elif [[ -e $path && ! -d $path ]]; then
    abort "$path conflicts with a managed directory"
  fi
}

parent_resolves_into_managed_repo() {
  local path=$1 parent
  parent=$(realpath -e -- "$(dirname -- "$path")") || return 1
  is_managed_target "$parent"
}

prepare_leaf() {
  local path=$1
  under_replaced_dir "$path" && return
  if [[ -e $path || -L $path ]]; then
    parent_resolves_into_managed_repo "$path" &&
      abort "$path sits under a parent that resolves into a managed repo; refusing to remove repo content"
    if [[ -L $path ]]; then
      queue_managed_link "$path"
    elif [[ -f $path ]]; then
      abort "$path is a regular file; compare or move it before retrying"
    else
      abort "$path is an unrecognized directory or special file"
    fi
  fi
}

# Shared and mutable roots stay real so runtime files cannot land in a repo.
for path in \
  "$HOME/.config" \
  "$HOME/.config/btop" \
  "$HOME/.config/btop/themes" \
  "$HOME/.config/git" \
  "$HOME/.config/nvim" \
  "$HOME/.config/nvim/lua" \
  "$HOME/.config/nvim/lua/config" \
  "$HOME/.config/nvim/lua/plugins" \
  "$HOME/.config/opencode" \
  "$HOME/.config/opencode/themes" \
  "$HOME/.config/yazi"; do
  prepare_real_dir "$path"
done

# These immutable package trees may be folded by Stow and can be removed as a
# unit when they still resolve into EyrWSL or EyrAgents. New package parents
# must be classified here or as real roots; unclassified repo parents abort.
for path in \
  "$HOME/.config/bash/functions" \
  "$HOME/.config/bash" \
  "$HOME/.config/fastfetch" \
  "$HOME/.config/nvim/after" \
  "$HOME/.config/opencode/agents" \
  "$HOME/.config/opencode/commands" \
  "$HOME/.config/opencode/node_modules" \
  "$HOME/.config/opencode/plugins" \
  "$HOME/.config/opencode/skills" \
  "$HOME/.config/opencode/tools" \
  "$HOME/.config/tmux"; do
  prepare_fold_dir "$path"
done

while IFS= read -r source; do
  [[ ${source##*/} == .gitignore ]] && continue
  prepare_leaf "$HOME/${source#*/}"
done < <(git -C "$repo" ls-files --cached --others --exclude-standard -- "${packages[@]}")

if [[ -d $ai_repo ]]; then
  while IFS= read -r source; do
    [[ ${source##*/} == .gitignore ]] && continue
    prepare_leaf "$HOME/${source#*/}"
  done < <(git -C "$ai_repo" ls-files --cached --others --exclude-standard -- opencode)
fi

# Mutation begins only after every endpoint passes preflight.
for path in "${remove_links[@]}"; do
  rm -- "$path"
  printf 'removed managed symlink: %s\n' "$path"
done
for path in "${create_dirs[@]}"; do
  mkdir -p -- "$path"
done
