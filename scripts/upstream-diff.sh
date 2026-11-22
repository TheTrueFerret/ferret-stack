#!/usr/bin/env bash
# Shows what poteto changed in pstack since the commit recorded in UPSTREAM.
# Usage: scripts/upstream-diff.sh [ref=main] [--full]
#   default prints a file summary; --full prints the whole diff.
set -euo pipefail
repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
base="$(awk '/^commit:/ {print $2}' "$repo/UPSTREAM")"
ref="${1:-main}"; full="${2:-}"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/ferret-stack/upstream"
if [[ ! -d "$cache/.git" ]]; then git clone -q --filter=blob:none https://github.com/cursor/plugins.git "$cache"; fi
git -C "$cache" fetch -q origin "$ref"
new="$(git -C "$cache" rev-parse FETCH_HEAD)"
echo "recorded: ${base:0:7}   upstream $ref: ${new:0:7}"
if [[ "$base" == "$new" ]]; then echo "no upstream changes"; exit 0; fi
git -C "$cache" log --oneline "$base..$new" -- pstack
if [[ "$full" == "--full" ]]; then git -C "$cache" diff "$base" "$new" -- pstack
else git -C "$cache" diff --stat "$base" "$new" -- pstack; fi
