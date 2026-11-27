#!/usr/bin/env bash
# Updates the vendored LLD and mold tests from pinned upstream commits.
#
# Usage:
#   ./update-tests.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

update_tests() (
    local test_name="$1" git_url="$2" upstream_path="$3" commit="$4"
    local dest="$SCRIPT_DIR/$test_name"
    local tmp_clone revision

    tmp_clone="$(mktemp -d)"
    trap 'rm -rf "$tmp_clone"' EXIT

    echo "Fetching $upstream_path at $commit from $git_url..."
    git -C "$tmp_clone" init -q
    git -C "$tmp_clone" remote add origin "$git_url"
    git -C "$tmp_clone" sparse-checkout set "$upstream_path"
    git -C "$tmp_clone" fetch --filter=blob:none --depth=1 origin "$commit"
    git -C "$tmp_clone" checkout --detach FETCH_HEAD
    revision="$(git -C "$tmp_clone" rev-parse HEAD)"

    mkdir -p "$dest"
    # Mirror the upstream directory, deleting stale tests.
    rsync -a --delete "$tmp_clone/$upstream_path/" "$dest/"

    printf '%s\n' "$revision" > "$dest/REVISION.txt"
    echo "Vendored $upstream_path ($revision) to $dest"
)

update_tests llvm-tests https://github.com/llvm/llvm-project.git lld/test bfb662baf51dfc6e5c75b98c0f913cdbcbec96ad
update_tests mold-tests https://github.com/rui314/mold.git test 3eca43961ddc8a5f6c670358cda2be8d326a5f96
