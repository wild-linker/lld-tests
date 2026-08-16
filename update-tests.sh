#!/usr/bin/env bash
# Updates the vendored LLD tests from upstream llvm-project.
#
# Usage:
#   ./update-tests.sh
#
# Fetches a sparse, shallow clone of just lld/test/ from
# https://github.com/llvm/llvm-project and syncs it into ./test.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$SCRIPT_DIR/test"

TMP_CLONE="$(mktemp -d)"
trap 'rm -rf "$TMP_CLONE"' EXIT

echo "Fetching lld/test from llvm-project..."
git clone --filter=blob:none --sparse --depth=1 \
    https://github.com/llvm/llvm-project.git "$TMP_CLONE"
git -C "$TMP_CLONE" sparse-checkout set lld/test
REVISION=$(git -C $TMP_CLONE reflog -1 --format=%H)

mkdir -p "$DEST"

# Mirror the upstream test directory, removing anything locally that no
# longer exists upstream, so stale/removed tests don't linger.
rsync -a --delete "$TMP_CLONE/lld/test/" "$DEST/"

echo $REVISION > REVISION.txt
echo "Vendored lld/test ($REVISION) to $DEST"
