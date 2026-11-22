#!/usr/bin/env bash
# Links the stack into Claude Code and Codex.
#   skills/*      -> ~/.claude/skills/<name> and ~/.codex/skills/<name>
#   agents/*.md   -> ~/.claude/agents/<name>.md
# Usage: scripts/install.sh              install (safe to run again)
#        scripts/install.sh --uninstall  remove only links that point into this repo
set -euo pipefail
repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mode="${1:-install}"
link() { # link <source> <target>
  local src="$1" dst="$2"
  if [[ "$mode" == "--uninstall" ]]; then
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then rm "$dst"; echo "removed $dst"; fi
    return
  fi
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then return; fi
  if [[ -e "$dst" || -L "$dst" ]]; then echo "skip $dst: something else is already there" >&2; return; fi
  mkdir -p "$(dirname "$dst")"; ln -s "$src" "$dst"; echo "linked $dst"
}
for skill in "$repo"/skills/*/; do
  name="$(basename "$skill")"
  link "${skill%/}" "$HOME/.claude/skills/$name"
  link "${skill%/}" "$HOME/.codex/skills/$name"
done
for agent in "$repo"/agents/*.md; do
  link "$agent" "$HOME/.claude/agents/$(basename "$agent")"
done
