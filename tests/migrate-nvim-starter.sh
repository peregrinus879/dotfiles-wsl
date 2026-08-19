#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

make_starter() {
  local home=$1 relative
  mkdir -p "$home/.config/nvim/lua/config"
  for relative in init.lua lua/config/autocmds.lua lua/config/keymaps.lua .neoconf.json; do
    cp "$ROOT/nvim/.config/nvim/$relative" "$home/.config/nvim/$relative"
  done
  awk '{ sub(/"gruvbox"/, "\"tokyonight\""); print }' \
    "$ROOT/nvim/.config/nvim/lua/config/lazy.lua" >"$home/.config/nvim/lua/config/lazy.lua"
  printf 'indent_type = "Spaces"\nindent_width = 2\ncolumn_width = 120' >"$home/.config/nvim/stylua.toml"
  printf '{"host-generated":true}\n' >"$home/.config/nvim/lazy-lock.json"
  printf 'starter leftover\n' >"$home/.config/nvim/README.md"
}

run_migration() {
  HOME=$1 bash "$ROOT/scripts/migrate-nvim-starter.sh"
}

assert_managed_links() {
  local home=$1 relative
  for relative in init.lua lua/config/lazy.lua lua/config/autocmds.lua lua/config/keymaps.lua \
    .neoconf.json stylua.toml lazy-lock.json; do
    [[ $(readlink -f "$home/.config/nvim/$relative") == $(readlink -f "$ROOT/nvim/.config/nvim/$relative") ]] ||
      fail "$relative does not resolve to its managed source"
  done
}

case_exact_starter_and_rerun() {
  local home="$TMP/exact/home" backups relative
  mkdir -p "$home"
  make_starter "$home"
  run_migration "$home" >/dev/null 2>&1
  assert_managed_links "$home"
  backups=("$home"/.config/nvim.eyrwsl-backup-*)
  [[ ${#backups[@]} == 1 ]] || fail "exact migration did not create one backup"
  for relative in init.lua lua/config/lazy.lua lua/config/autocmds.lua lua/config/keymaps.lua \
    .neoconf.json stylua.toml lazy-lock.json; do
    [[ -f ${backups[0]}/$relative ]] || fail "exact migration backup omitted $relative"
  done
  [[ $(<"${backups[0]}/lazy-lock.json") == '{"host-generated":true}' ]] || fail "generated lock was not backed up"
  [[ $(<"$home/.config/nvim/README.md") == "starter leftover" ]] || fail "unrelated starter file changed"
  run_migration "$home" >/dev/null 2>&1
  backups=("$home"/.config/nvim.eyrwsl-backup-*)
  [[ ${#backups[@]} == 1 ]] || fail "idempotent rerun created another backup"
}

case_modified_static_is_atomic() {
  local home="$TMP/modified/home" backups
  mkdir -p "$home"
  make_starter "$home"
  printf '%s\n' '-- local change' >>"$home/.config/nvim/lua/config/autocmds.lua"
  if run_migration "$home" >/dev/null 2>&1; then
    fail "modified static starter file did not abort"
  fi
  [[ -f $home/.config/nvim/init.lua ]] || fail "modified-file abort removed another starter file"
  [[ -f $home/.config/nvim/lua/config/autocmds.lua ]] || fail "modified starter file was removed"
  backups=("$home"/.config/nvim.eyrwsl-backup-*)
  [[ ${#backups[@]} == 0 ]] || fail "modified-file abort created a backup"
}

case_foreign_symlink() {
  local home="$TMP/foreign/home" foreign="$TMP/foreign/init.lua" backups
  mkdir -p "$home" "$(dirname -- "$foreign")"
  make_starter "$home"
  rm -- "$home/.config/nvim/init.lua"
  printf 'foreign\n' >"$foreign"
  ln -s "$foreign" "$home/.config/nvim/init.lua"
  if run_migration "$home" >/dev/null 2>&1; then
    fail "foreign starter symlink did not abort"
  fi
  [[ -L $home/.config/nvim/init.lua ]] || fail "foreign starter symlink was removed"
  [[ -f $home/.config/nvim/lua/config/lazy.lua ]] || fail "foreign-link abort removed another file"
  backups=("$home"/.config/nvim.eyrwsl-backup-*)
  [[ ${#backups[@]} == 0 ]] || fail "foreign-link abort created a backup"
}

case_foreign_parent_symlink() {
  local home="$TMP/foreign-parent/home" foreign="$TMP/foreign-parent/lua" backups
  mkdir -p "$home/.config/nvim" "$foreign/config"
  awk '{ sub(/"gruvbox"/, "\"tokyonight\""); print }' \
    "$ROOT/nvim/.config/nvim/lua/config/lazy.lua" >"$foreign/config/lazy.lua"
  ln -s "$foreign" "$home/.config/nvim/lua"
  if run_migration "$home" >/dev/null 2>&1; then
    fail "foreign parent symlink did not abort"
  fi
  [[ -f $foreign/config/lazy.lua ]] || fail "foreign parent abort removed external content"
  backups=("$home"/.config/nvim.eyrwsl-backup-*)
  [[ ${#backups[@]} == 0 ]] || fail "foreign-parent abort created a backup"
}

case_partial_path_set() {
  local home="$TMP/partial/home" backups
  mkdir -p "$home/.config/nvim"
  cp "$ROOT/nvim/.config/nvim/init.lua" "$home/.config/nvim/init.lua"
  printf '{"different-lock":true}\n' >"$home/.config/nvim/lazy-lock.json"
  run_migration "$home" >/dev/null 2>&1
  assert_managed_links "$home"
  backups=("$home"/.config/nvim.eyrwsl-backup-*)
  [[ ${#backups[@]} == 1 ]] || fail "partial migration did not create one backup"
  [[ -f ${backups[0]}/init.lua && -f ${backups[0]}/lazy-lock.json ]] || fail "partial migration backup is incomplete"
  [[ ! -e ${backups[0]}/stylua.toml ]] || fail "partial migration invented an absent backup file"
}

case_exact_starter_and_rerun
case_modified_static_is_atomic
case_foreign_symlink
case_foreign_parent_symlink
case_partial_path_set
printf 'ok: Neovim starter migration is backup-first and fail-closed\n'
