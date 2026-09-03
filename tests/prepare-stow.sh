#!/usr/bin/env bash
# Fixtures for scripts/prepare-stow.sh: a fake HOME holding a fake clone with
# this repo's package shape, laid out as Stow links it. Leftover folded links
# and dangling links from a moved clone are removed; live leaf links, repo
# content, and unowned entries are untouched; a regular file or anything
# unrecognized aborts before any removal; the WSL gate holds; a no-folding
# deployment keeps every managed parent real so host-local files never reach
# a package source.
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
PACKAGES='bash git nvim yazi'
WSL_KERNEL='6.6.0-microsoft-standard-WSL2'

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

# A clone at $home/Projects/eyrwsl with the package shape that matters, so
# relative link text resolves the way Stow writes it under $HOME.
make_clone() {
  local repo=$1
  mkdir -p "$repo/bash/.config/bash" "$repo/git/.config/git" "$repo/nvim/.config/nvim/lua/config" \
    "$repo/yazi/.config/yazi" "$repo/scripts"
  printf 'bashrc\n' >"$repo/bash/.bashrc"
  printf 'envs\n' >"$repo/bash/.config/bash/envs"
  printf '[init]\n\tdefaultBranch = main\n' >"$repo/git/.config/git/config"
  printf 'init\n' >"$repo/nvim/.config/nvim/init.lua"
  printf 'options\n' >"$repo/nvim/.config/nvim/lua/config/options.lua"
  printf 'yazi\n' >"$repo/yazi/.config/yazi/yazi.toml"
  cp -- "$ROOT/scripts/prepare-stow.sh" "$repo/scripts/prepare-stow.sh"
  git -C "$repo" init -q
  git -C "$repo" add -A
}

prepare() { # home repo [kernel]
  HOME=$1 EYRWSL_PACKAGES=$PACKAGES PREPARE_STOW_KERNEL_RELEASE=${3:-$WSL_KERNEL} bash "$2/scripts/prepare-stow.sh"
}
# shellcheck disable=SC2086
deploy() { stow --no-folding -R -d "$2" -t "$1" $PACKAGES; }

snapshot() {
  (cd -- "$1" && find . -path ./.git -prune -o -type f -print0 | sort -z | xargs -0 sha256sum)
}

case_fresh_home() {
  local home="$TMP/fresh/home" repo="$TMP/fresh/home/Projects/eyrwsl"
  mkdir -p "$home"
  make_clone "$repo"
  prepare "$home" "$repo" >/dev/null || fail "fresh home did not succeed"
  [[ $(ls -A "$home") == Projects ]] || fail "fresh home was changed"
}

case_owned_entries() {
  local home="$TMP/owned/home" repo="$TMP/owned/home/Projects/eyrwsl" before after path
  mkdir -p "$home/.config/git"
  make_clone "$repo"
  printf 'keymaps\n' >"$repo/nvim/.config/nvim/lua/config/keymaps.lua" # untracked package file
  ln -s Projects/eyrwsl/bash/.bashrc "$home/.bashrc"
  ln -s ../Projects/eyrwsl/bash/.config/bash "$home/.config/bash"
  ln -s ../Projects/eyrwsl/nvim/.config/nvim "$home/.config/nvim"
  ln -s ../Projects/eyrwsl/yazi/.config/yazi "$home/.config/yazi"
  ln -s ../../Projects/eyrwsl/git/.config/git/config "$home/.config/git/config"
  printf '[user]\n\tname = fixture\n' >"$home/.config/git/config.local"
  ln -s /usr/share/nothing/theme "$home/.config/git/theme"
  before=$(snapshot "$repo")
  prepare "$home" "$repo" >/dev/null || fail "owned entries did not succeed"
  after=$(snapshot "$repo")
  [[ $before == "$after" ]] || fail "owned-entry cleanup changed repo content"
  for path in .config/bash .config/nvim .config/yazi; do
    [[ ! -e $home/$path && ! -L $home/$path ]] || fail "leftover folded link remains: $path"
  done
  for path in .bashrc .config/git/config; do
    [[ -L $home/$path ]] || fail "live leaf link was removed: $path"
  done
  [[ -d $home/.config/git && ! -L $home/.config/git ]] || fail "real git parent was touched"
  [[ $(<"$home/.config/git/config.local") == *fixture ]] || fail "unowned regular file was changed"
  [[ -L $home/.config/git/theme ]] || fail "unowned link was removed"
  [[ -f $repo/nvim/.config/nvim/lua/config/keymaps.lua ]] || fail "content under a folded parent was removed from the repo"
}

case_no_folding() {
  local home="$TMP/nofold/home" repo="$TMP/nofold/home/Projects/eyrwsl" path
  mkdir -p "$home/.config/git"
  make_clone "$repo"
  printf '[user]\n\tname = fixture\n' >"$home/.config/git/config.local"
  # Folded links as a folding deployment created them: relative, so Stow still
  # recognizes them as its own.
  ln -s ../Projects/eyrwsl/nvim/.config/nvim "$home/.config/nvim"
  ln -s ../Projects/eyrwsl/yazi/.config/yazi "$home/.config/yazi"
  prepare "$home" "$repo" >/dev/null || fail "leftover folds did not succeed"
  deploy "$home" "$repo" >/dev/null 2>&1 || fail "no-folding stow failed after cleanup"
  for path in .config/bash .config/git .config/nvim .config/nvim/lua/config .config/yazi; do
    [[ -d $home/$path && ! -L $home/$path ]] || fail "$path is not a real directory after no-folding stow"
  done
  [[ $(readlink -f -- "$home/.config/nvim/lua/config/options.lua") == "$repo/nvim/.config/nvim/lua/config/options.lua" ]] ||
    fail "leaf link does not resolve into the clone"
  printf 'host-local\n' >"$home/.config/yazi/package.toml"
  prepare "$home" "$repo" >/dev/null || fail "cleanup with live links failed"
  [[ -L $home/.bashrc && -L $home/.config/yazi/yazi.toml ]] || fail "cleanup removed a live leaf link"
  deploy "$home" "$repo" >/dev/null 2>&1 || fail "restow failed with host-local state present"
  [[ $(<"$home/.config/yazi/package.toml") == host-local && $(<"$home/.config/git/config.local") == *fixture ]] ||
    fail "restow changed host-local state"
  [[ ! -e $repo/yazi/.config/yazi/package.toml && ! -e $repo/git/.config/git/config.local ]] ||
    fail "host-local state reached the package source"
}

case_regular_file() {
  local home="$TMP/regular/home" repo="$TMP/regular/home/Projects/eyrwsl"
  mkdir -p "$home/.config"
  make_clone "$repo"
  printf 'skel\n' >"$home/.bashrc"
  ln -s ../Projects/eyrwsl/yazi/.config/yazi "$home/.config/yazi"
  if prepare "$home" "$repo" >/dev/null 2>&1; then fail "regular file at an owned path did not abort"; fi
  [[ $(<"$home/.bashrc") == skel ]] || fail "regular file was changed"
  [[ -L $home/.config/yazi ]] || fail "abort was not atomic: a folded link was removed first"
}

case_moved_clone() {
  local home="$TMP/moved/home" repo="$TMP/moved/home/Projects/eyrwsl" path
  mkdir -p "$home/.config/git"
  make_clone "$repo"
  ln -s Projects/old/eyrwsl/bash/.bashrc "$home/.bashrc"
  ln -s ../Projects/old/eyrwsl/yazi/.config/yazi "$home/.config/yazi"
  ln -s "$TMP/moved/elsewhere/eyrwsl/git/.config/git/config" "$home/.config/git/config"
  prepare "$home" "$repo" >/dev/null || fail "moved-clone links did not succeed"
  for path in .bashrc .config/yazi .config/git/config; do
    [[ ! -L $home/$path ]] || fail "dangling link from a moved clone remains: $path"
  done
}

case_dangling_unrelated() {
  local home="$TMP/dangling/home" repo="$TMP/dangling/home/Projects/eyrwsl"
  mkdir -p "$home/.config/git"
  make_clone "$repo"
  ln -s Projects/old/eyrwsl/bash/.bashrc "$home/.bashrc"
  ln -s /usr/share/git/config "$home/.config/git/config"
  if prepare "$home" "$repo" >/dev/null 2>&1; then fail "dangling link outside the package layout did not abort"; fi
  [[ -L $home/.config/git/config ]] || fail "dangling unrelated link was removed"
  [[ -L $home/.bashrc ]] || fail "abort was not atomic: a dangling clone link was removed first"
}

case_foreign_link() {
  local home="$TMP/foreign/home" repo="$TMP/foreign/home/Projects/eyrwsl" foreign="$TMP/foreign/user-config"
  mkdir -p "$home/.config/git"
  make_clone "$repo"
  printf 'foreign\n' >"$foreign"
  ln -s Projects/old/eyrwsl/bash/.bashrc "$home/.bashrc"
  ln -s "$foreign" "$home/.config/git/config"
  if prepare "$home" "$repo" >/dev/null 2>&1; then fail "foreign link did not abort"; fi
  [[ -L $home/.config/git/config && $(<"$foreign") == foreign ]] || fail "foreign link or its target was changed"
  [[ -L $home/.bashrc ]] || fail "abort was not atomic: a dangling clone link was removed first"
}

case_foreign_fold() {
  local home="$TMP/fold/home" repo="$TMP/fold/home/Projects/eyrwsl" other="$TMP/fold/other-yazi"
  mkdir -p "$home/.config" "$other"
  make_clone "$repo"
  printf 'other\n' >"$other/yazi.toml"
  ln -s ../Projects/eyrwsl/bash/.config/bash "$home/.config/bash"
  ln -s "$other" "$home/.config/yazi"
  if prepare "$home" "$repo" >/dev/null 2>&1; then fail "foreign directory link did not abort"; fi
  [[ -L $home/.config/yazi && $(<"$other/yazi.toml") == other ]] || fail "foreign directory link or its content was changed"
  [[ -L $home/.config/bash ]] || fail "abort was not atomic: a folded link was removed first"
}

case_special_file() {
  local home="$TMP/special/home" repo="$TMP/special/home/Projects/eyrwsl"
  mkdir -p "$home"
  make_clone "$repo"
  mkfifo "$home/.bashrc"
  if prepare "$home" "$repo" >/dev/null 2>&1; then fail "special file did not abort"; fi
  [[ -p $home/.bashrc ]] || fail "special file was removed"
}

case_directory_at_leaf() {
  local home="$TMP/dirleaf/home" repo="$TMP/dirleaf/home/Projects/eyrwsl"
  mkdir -p "$home/.bashrc"
  make_clone "$repo"
  if prepare "$home" "$repo" >/dev/null 2>&1; then fail "directory at a leaf path did not abort"; fi
  [[ -d $home/.bashrc ]] || fail "directory at a leaf path was removed"
}

case_missing_packages() {
  local home="$TMP/nopkg/home" repo="$TMP/nopkg/home/Projects/eyrwsl"
  mkdir -p "$home"
  make_clone "$repo"
  if HOME=$home EYRWSL_PACKAGES='' PREPARE_STOW_KERNEL_RELEASE=$WSL_KERNEL bash "$repo/scripts/prepare-stow.sh" >/dev/null 2>&1; then
    fail "empty EYRWSL_PACKAGES did not abort"
  fi
}

case_wsl_gate() {
  local home="$TMP/gate/home" repo="$TMP/gate/home/Projects/eyrwsl"
  mkdir -p "$home/.config"
  make_clone "$repo"
  ln -s ../Projects/eyrwsl/yazi/.config/yazi "$home/.config/yazi"
  if prepare "$home" "$repo" linux-fixture >/dev/null 2>&1; then fail "non-WSL kernel did not abort"; fi
  [[ -L $home/.config/yazi ]] || fail "non-WSL abort removed a link"
}

case_fresh_home
case_owned_entries
case_no_folding
case_regular_file
case_moved_clone
case_dangling_unrelated
case_foreign_link
case_foreign_fold
case_special_file
case_directory_at_leaf
case_missing_packages
case_wsl_gate
printf 'ok:   prepare-stow removes leftover folds and dangling clone links, keeps live links and user files, and aborts untouched otherwise\n'
