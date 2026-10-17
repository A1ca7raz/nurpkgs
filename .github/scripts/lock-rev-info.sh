#!/usr/bin/env bash
# lock-rev-info.sh <flake.lock> <input>
#
# Prints the locked revision of <input> as "<short-rev> (<yyyymmdd>)",
# e.g. "a1b2c3d (20260926)". Used by the update workflows to render
# flake.lock diffs in PR bodies and Telegram notifications.
#
# <input> is resolved through .nodes.root.inputs, NOT by node name:
# nix renames lock nodes when inputs gain or lose follows (e.g. the
# root "systems" input became node "systems_2" after colmena introduced
# its own unfollowed "systems"), so .nodes[$name] is not reliable.
# Unknown/removed inputs print "unknown (unknown)".

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: lock-rev-info.sh <flake.lock> <input>" >&2
  exit 2
fi

jq -r --arg n "$2" '
  . as $l
  # Resolve an input reference to a node name. A string is the node name
  # itself; an array is a follows path walked from the root.
  | def resolve($e):
      if ($e | type) == "string" then $e
      elif ($e | type) == "array" then
        reduce $e[] as $p ("root"; resolve($l.nodes[.].inputs[$p]))
      else null end;
  (if $l.nodes.root.inputs[$n] then ($l.nodes[resolve($l.nodes.root.inputs[$n])].locked) else null end)
  | "\(((.rev // "unknown"))[:7]) (\(if .lastModified then (.lastModified | todate | .[:10] | gsub("-"; "")) else "unknown" end))"
' "$1"
