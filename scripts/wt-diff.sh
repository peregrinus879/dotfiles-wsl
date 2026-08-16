#!/usr/bin/env bash
# Diff the tracked Windows Terminal settings.json against the deployed
# Windows-side file. Run from the repo root on the WSL machine.
#
# Usage: scripts/wt-diff.sh [--pull]
#   --pull  copy the deployed file into the repo for review instead of diffing
#
# Set WT_SETTINGS to the deployed file path to skip auto-detection.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tracked="${repo_root}/windows-terminal/settings.json"

deployed="${WT_SETTINGS:-}"
if [[ -z "${deployed}" ]]; then
  for candidate in /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json; do
    if [[ -f "${candidate}" ]]; then
      deployed="${candidate}"
      break
    fi
  done
fi

if [[ -z "${deployed}" || ! -f "${deployed}" ]]; then
  echo "error: deployed settings.json not found; set WT_SETTINGS to its path" >&2
  exit 2
fi

if [[ "${1:-}" == "--pull" ]]; then
  # Strip a possible UTF-8 BOM so it never lands in the tracked file, where
  # the normalized diff below could not see it.
  sed '1s/^\xEF\xBB\xBF//' "${deployed}" > "${tracked}"
  echo "pulled deployed settings into the repo; review with: git diff -- windows-terminal/settings.json"
  exit 0
fi

# Normalize before diffing: Windows Terminal rewrites the deployed file with
# its own key order and may prepend a UTF-8 BOM, so a plain checksum would
# always report drift.
normalize() {
  sed '1s/^\xEF\xBB\xBF//' "$1" | jq -S .
}

echo "tracked:  ${tracked}"
echo "deployed: ${deployed}"

if diff -u <(normalize "${tracked}") <(normalize "${deployed}"); then
  echo "no drift: tracked and deployed settings match"
else
  echo
  echo "drift detected ('+' lines are the deployed side); adopt with: make wt-pull"
  exit 1
fi
