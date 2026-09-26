#!/usr/bin/env bash
# drv-diff.sh <base> <head>
#
# Diffs the derivation paths of all buildable flake outputs
# (.#packages / .#legacyPackages / .#checks on x86_64-linux) between two
# revisions of this repository and prints a JSON array of "<output>.<attr>"
# strings for entries whose drvPath changed, was added, or was removed.
#
# <base> and <head> may each be a git ref (checked out into a temporary
# worktree) or a path to a directory containing a checkout. Directory
# arguments are evaluated as-is: with a dirty working tree, stage changes
# first (`git add -A`) or the flake will not see them.
#
# Failure rules:
#   - head evaluation failure -> exit 1
#   - base evaluation failure -> print ALL head entries (fallback full build)
#
# Runnable locally: drv-diff.sh HEAD~1 HEAD

set -euo pipefail

SYSTEM="x86_64-linux"
OUTPUTS=("packages" "legacyPackages" "checks")

log() { printf '[drv-diff] %s\n' "$*" >&2; }

if [ "$#" -ne 2 ]; then
  log "usage: drv-diff.sh <base> <head>"
  exit 2
fi

for cmd in git nix jq; do
  command -v "$cmd" > /dev/null || { log "ERROR: '$cmd' not found in PATH"; exit 2; }
done

BASE=$1
HEAD=$2

REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREES=()

cleanup() {
  local wt
  for wt in ${WORKTREES[@]+"${WORKTREES[@]}"}; do
    log "removing worktree $wt"
    git -C "$REPO_ROOT" worktree remove --force "$wt" || true
  done
}
trap cleanup EXIT

# resolve_target <ref-or-dir>: sets TARGET_DIR to a directory with the checkout.
TARGET_DIR=
resolve_target() {
  local target=$1 wt
  if [ -d "$target" ]; then
    TARGET_DIR=$(cd "$target" && pwd)
    log "using directory $TARGET_DIR"
    return 0
  fi
  if git -C "$REPO_ROOT" rev-parse --verify --quiet "${target}^{commit}" > /dev/null; then
    wt=$(mktemp -d /tmp/drv-diff.XXXXXX)
    log "checking out $target into worktree $wt"
    git -C "$REPO_ROOT" worktree add --detach "$wt" "$target" >&2
    WORKTREES+=("$wt")
    TARGET_DIR=$wt
    return 0
  fi
  log "ERROR: '$target' is neither a directory nor a git ref"
  return 1
}

# eval_drvs <dir>: print a JSON object mapping "<output>.<attr>" -> drvPath.
# Non-derivation attributes map to null (they only matter if they ever
# become derivations, which shows up as a null -> path change).
eval_drvs() {
  local dir=$1 output json
  local maps=()
  for output in "${OUTPUTS[@]}"; do
    if ! json=$(cd "$dir" && nix eval --json ".#${output}.${SYSTEM}" \
      --apply 'builtins.mapAttrs (_: drv: drv.drvPath or null)'); then
      log "ERROR: evaluation of .#${output}.${SYSTEM} failed in $dir"
      return 1
    fi
    maps+=("$(jq --arg o "$output" \
      '[to_entries[] | {key: "\($o).\(.key)", value: .value}] | from_entries' \
      <<< "$json")")
  done
  printf '%s\n' "${maps[@]}" | jq -s 'add'
}

resolve_target "$BASE"
BASE_DIR=$TARGET_DIR
resolve_target "$HEAD"
HEAD_DIR=$TARGET_DIR

if ! HEAD_JSON=$(eval_drvs "$HEAD_DIR"); then
  log "head ($HEAD) evaluation failed"
  exit 1
fi

if ! BASE_JSON=$(eval_drvs "$BASE_DIR"); then
  log "base ($BASE) evaluation failed; falling back to full build"
  jq -c --argjson head "$HEAD_JSON" '$head | keys' <<< '{}'
  exit 0
fi

jq -cn --argjson base "$BASE_JSON" --argjson head "$HEAD_JSON" '
  (($base | keys) + ($head | keys) | unique) as $ks |
  [$ks[] | select(($base[.] // null) != ($head[.] // null))]'
