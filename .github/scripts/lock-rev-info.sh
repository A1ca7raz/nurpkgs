#!/usr/bin/env bash
# lock-rev-info.sh <flake.lock> <input>
#
# Prints the locked revision of <input> as "<short-rev> (<yyyymmdd>)",
# e.g. "a1b2c3d (20260926)". Used by the update workflows to render
# flake.lock diffs in PR bodies and Telegram notifications.

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: lock-rev-info.sh <flake.lock> <input>" >&2
  exit 2
fi

jq -r --arg n "$2" '
  .nodes[$n].locked
  | "\((.rev // "unknown")[:7]) (\(if .lastModified then (.lastModified | todate | .[:10] | gsub("-"; "")) else "unknown" end))"
' "$1"
