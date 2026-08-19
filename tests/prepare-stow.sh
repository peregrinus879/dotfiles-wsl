#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
AI_ROOT="$TMP/eyragents"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

run_prepare() {
  HOME=$1 EYRAGENTS_REPO=$AI_ROOT bash "$ROOT/scripts/prepare-stow.sh"
}

make_ai_payload() {
  mkdir -p "$AI_ROOT/opencode/.config/opencode/agents"
  printf '{}\n' >"$AI_ROOT/opencode/.config/opencode/opencode.json"
  git -C "$AI_ROOT" init -q
  git -C "$AI_ROOT" add opencode
}

case_fresh_home() {
  local home="$TMP/fresh/home" path
  mkdir -p "$home"
  run_prepare "$home" >/dev/null
  for path in .config .config/btop .config/btop/themes .config/git .config/nvim \
    .config/nvim/lua/config .config/nvim/lua/plugins .config/opencode \
    .config/opencode/themes .config/yazi; do
    [[ -d $home/$path && ! -L $home/$path ]] || fail "fresh $path is not a real directory"
  done
}

case_owned_links() {
  local home="$TMP/owned/home"
  mkdir -p "$home/.config"
  ln -s "$ROOT/bash/.config/bash" "$home/.config/bash"
  ln -s "$ROOT/tmux/.config/tmux" "$home/.config/tmux"
  ln -s "$ROOT/bash/.bashrc" "$home/.bashrc"
  run_prepare "$home" >/dev/null
  [[ ! -e $home/.config/bash && ! -L $home/.config/bash ]] || fail "owned Bash fold remains"
  [[ ! -e $home/.config/tmux && ! -L $home/.config/tmux ]] || fail "owned tmux fold remains"
  [[ ! -e $home/.bashrc && ! -L $home/.bashrc ]] || fail "owned file link remains"
}

case_mutable_directories() {
  local home="$TMP/mutable/home" before after
  mkdir -p "$home/.config"
  before=$(sha256sum "$ROOT/yazi/.config/yazi/yazi.toml")
  ln -s "$ROOT/btop/.config/btop" "$home/.config/btop"
  ln -s "$ROOT/yazi/.config/yazi" "$home/.config/yazi"
  run_prepare "$home" >/dev/null
  after=$(sha256sum "$ROOT/yazi/.config/yazi/yazi.toml")
  [[ $before == "$after" ]] || fail "mutable-directory preparation changed repo content"
  [[ -d $home/.config/btop && ! -L $home/.config/btop ]] || fail "btop root is not real"
  [[ -d $home/.config/btop/themes && ! -L $home/.config/btop/themes ]] || fail "btop themes root is not real"
  [[ -d $home/.config/yazi && ! -L $home/.config/yazi ]] || fail "Yazi root is not real"
}

case_opencode_merge() {
  local home="$TMP/opencode/home"
  mkdir -p "$home/.config/opencode/themes"
  printf 'preserve\n' >"$home/.config/opencode/local-note"
  ln -s "$AI_ROOT/opencode/.config/opencode/agents" "$home/.config/opencode/agents"
  ln -s "$AI_ROOT/opencode/.config/opencode/opencode.json" "$home/.config/opencode/opencode.json"
  run_prepare "$home" >/dev/null
  [[ $(<"$home/.config/opencode/local-note") == preserve ]] || fail "OpenCode user content changed"
  [[ -d $home/.config/opencode && ! -L $home/.config/opencode ]] || fail "OpenCode root is not real"
  [[ -d $home/.config/opencode/themes && ! -L $home/.config/opencode/themes ]] || fail "OpenCode themes root is not real"
  [[ ! -e $home/.config/opencode/agents ]] || fail "managed OpenCode directory link remains"
  [[ ! -e $home/.config/opencode/opencode.json ]] || fail "managed OpenCode file link remains"
}

case_folded_parent_safety() {
  local home="$TMP/folded/home" before after
  mkdir -p "$home/.config"
  before=$(sha256sum "$ROOT/bash/.config/bash/envs")
  ln -s "$ROOT/bash/.config/bash" "$home/.config/bash"
  run_prepare "$home" >/dev/null
  after=$(sha256sum "$ROOT/bash/.config/bash/envs")
  [[ $before == "$after" ]] || fail "folded-parent cleanup changed repo content"
  [[ ! -e $home/.config/bash && ! -L $home/.config/bash ]] || fail "folded parent remains"
}

case_repo_resolving_parent_is_atomic() {
  local home="$TMP/repo-parent/home" before after
  mkdir -p "$home/.config/nvim/after"
  before=$(sha256sum "$ROOT/nvim/.config/nvim/after/plugin/transparency.lua")
  ln -s "$ROOT/bash/.bashrc" "$home/.bashrc"
  ln -s "$ROOT/nvim/.config/nvim/after/plugin" "$home/.config/nvim/after/plugin"
  if run_prepare "$home" >/dev/null 2>&1; then
    fail "repo-resolving parent did not abort"
  fi
  after=$(sha256sum "$ROOT/nvim/.config/nvim/after/plugin/transparency.lua")
  [[ $before == "$after" ]] || fail "repo-resolving parent changed repo content"
  [[ -L $home/.bashrc ]] || fail "repo-parent preflight partially removed a managed link"
  [[ -L $home/.config/nvim/after/plugin ]] || fail "repo-resolving parent was removed"
}

case_regular_conflict_is_atomic() {
  local home="$TMP/regular/home"
  mkdir -p "$home/.config"
  printf 'user data\n' >"$home/.bashrc"
  ln -s "$ROOT/tmux/.config/tmux" "$home/.config/tmux"
  if run_prepare "$home" >/dev/null 2>&1; then
    fail "regular-file conflict did not abort"
  fi
  [[ $(<"$home/.bashrc") == "user data" ]] || fail "regular-file conflict changed"
  [[ -L $home/.config/tmux ]] || fail "preflight failure partially removed a managed link"
}

case_foreign_link() {
  local home="$TMP/foreign/home" foreign="$TMP/foreign/user-file"
  mkdir -p "$home" "$(dirname -- "$foreign")"
  printf 'foreign\n' >"$foreign"
  ln -s "$foreign" "$home/.bashrc"
  if run_prepare "$home" >/dev/null 2>&1; then
    fail "foreign symlink did not abort"
  fi
  [[ -L $home/.bashrc ]] || fail "foreign symlink was removed"
}

case_broken_link() {
  local home="$TMP/broken/home"
  mkdir -p "$home"
  ln -s "$TMP/broken/missing" "$home/.bashrc"
  if run_prepare "$home" >/dev/null 2>&1; then
    fail "broken symlink did not abort"
  fi
  [[ -L $home/.bashrc ]] || fail "broken symlink was removed"
}

case_special_file() {
  local home="$TMP/special/home"
  mkdir -p "$home"
  mkfifo "$home/.bashrc"
  if run_prepare "$home" >/dev/null 2>&1; then
    fail "special-file conflict did not abort"
  fi
  [[ -p $home/.bashrc ]] || fail "special-file conflict was removed"
}

case_missing_ai_repo() {
  local home="$TMP/missing-ai-repo/home"
  mkdir -p "$home"
  if HOME="$home" EYRAGENTS_REPO='' EYRWSL_PACKAGES=fixture \
    bash "$ROOT/scripts/prepare-stow.sh" >/dev/null 2>&1; then
    fail "empty EYRAGENTS_REPO did not abort"
  fi
}

case_missing_ai_repo
case_fresh_home
make_ai_payload
case_owned_links
case_mutable_directories
case_opencode_merge
case_folded_parent_safety
case_repo_resolving_parent_is_atomic
case_regular_conflict_is_atomic
case_foreign_link
case_broken_link
case_special_file
printf 'ok: prepare-stow preflights ownership and preserves user data\n'
