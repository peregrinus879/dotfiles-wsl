#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
shopt -s nullglob

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

deployed="$TMP/settings.json"
original="$TMP/original.json"
printf '{"profiles":{"defaults":{}},"schemes":[]}\n' >"$deployed"
cp -- "$deployed" "$original"

WT_SETTINGS="$deployed" "$ROOT/scripts/wt-diff.sh" --push >/dev/null
cmp -s "$ROOT/windows-terminal/settings.json" "$deployed" || fail "push did not deploy tracked settings"

backups=("$deployed".backup-*)
(( ${#backups[@]} == 1 )) || fail "push did not create exactly one backup"
cmp -s "$original" "${backups[0]}" || fail "backup does not preserve deployed settings"

jq -S . "$deployed" >"$TMP/reordered.json"
mv -- "$TMP/reordered.json" "$deployed"
cmp -s "$ROOT/windows-terminal/settings.json" "$deployed" && fail "normalized fixture did not change file order"
WT_SETTINGS="$deployed" "$ROOT/scripts/wt-diff.sh" --push >/dev/null
backups=("$deployed".backup-*)
(( ${#backups[@]} == 1 )) || fail "normalized no-op push created another backup"
WT_SETTINGS="$deployed" "$ROOT/scripts/wt-diff.sh" >/dev/null || fail "deployed settings drift after push"

invalid="$TMP/invalid.json"
printf '{\n' >"$invalid"
if WT_SETTINGS="$invalid" "$ROOT/scripts/wt-diff.sh" --push >/dev/null 2>&1; then
  fail "invalid deployed JSON did not fail"
fi
invalid_backups=("$invalid".backup-*)
(( ${#invalid_backups[@]} == 0 )) || fail "invalid deployed JSON created a backup"

unstageable="$TMP/unstageable.json"
cp -- "$original" "$unstageable"
mkdir "$TMP/fail-bin"
printf '#!/usr/bin/env bash\nexit 1\n' >"$TMP/fail-bin/chmod"
chmod +x "$TMP/fail-bin/chmod"
if PATH="$TMP/fail-bin:$PATH" WT_SETTINGS="$unstageable" \
  "$ROOT/scripts/wt-diff.sh" --push >/dev/null 2>&1; then
  fail "unstageable deployment did not fail"
fi
unstageable_backups=("$unstageable".backup-*)
(( ${#unstageable_backups[@]} == 0 )) || fail "staging failure created a backup"
cmp -s "$original" "$unstageable" || fail "staging failure changed deployed settings"

set +e
"$ROOT/scripts/wt-diff.sh" --pull >/dev/null 2>&1
status=$?
set -e
[[ $status == 2 ]] || fail "unsupported mode did not return usage status"

printf 'ok: Windows Terminal push is validated, backup-first, and idempotent\n'
