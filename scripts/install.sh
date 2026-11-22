#!/usr/bin/env bash
# Links the Ferret Stack into Claude Code and Codex.
#   skills/*      -> ~/.claude/skills/<name> and ~/.codex/skills/<name>
#   agents/*.md   -> ~/.claude/agents/<name>.md
# Usage: scripts/install.sh              install links (safe to run again)
#        scripts/install.sh --default    also make ferret-mode the default for work tasks,
#                                        via a marked block in ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md
#        scripts/install.sh --uninstall  remove this repo's links and the default block
set -euo pipefail
repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mode="${1:-install}"
begin="<!-- ferret-stack:default:begin -->"
end="<!-- ferret-stack:default:end -->"

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

prune() { # remove links in <dir> that point into this repo but whose target is gone (renamed or deleted skills)
  local dir="$1" l
  [[ -d "$dir" ]] || return 0
  for l in "$dir"/*; do
    [[ -L "$l" ]] || continue
    case "$(readlink "$l")" in "$repo"/*) [[ -e "$l" ]] || { rm "$l"; echo "removed stale $l"; } ;; esac
  done
}

default_block() { # default_block <path to the skill file for this harness>
  cat <<BLOCK
$begin
## Ferret Stack default

When my message asks you to do work that changes something (write or fix code, edit files or config, refactor, build a feature, or open, update, or land a PR), work in ferret mode: read \`$1\` before anything else and follow it, even though I did not type \`/ferret-mode\`. Its "When this applies" section decides the edge cases.

When I ask a question, want an explanation, an opinion, or research, or just want to talk, answer normally without ferret mode. When unsure, answer normally. I can force it with \`/ferret-mode\` and skip it with "no ferret".
$end
BLOCK
}

set_default() { # set_default <instructions file> <skill file>
  local file="$1" skill="$2" tmp
  mkdir -p "$(dirname "$file")"; touch "$file"
  tmp="$(mktemp)"
  awk -v b="$begin" -v e="$end" '$0==b{skip=1} !skip{print} $0==e{skip=0}' "$file" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > "$tmp"
  if [[ "$mode" != "--uninstall" ]]; then
    { [[ -s "$tmp" ]] && printf '\n'; default_block "$skill"; } >> "$tmp"
  fi
  if ! cmp -s "$tmp" "$file"; then cat "$tmp" > "$file"; echo "updated $file"; fi
  rm -f "$tmp"
}

for dir in "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.claude/agents"; do prune "$dir"; done
for skill in "$repo"/skills/*/; do
  name="$(basename "$skill")"
  link "${skill%/}" "$HOME/.claude/skills/$name"
  link "${skill%/}" "$HOME/.codex/skills/$name"
done
for agent in "$repo"/agents/*.md; do
  link "$agent" "$HOME/.claude/agents/$(basename "$agent")"
done
if [[ "$mode" == "--default" || "$mode" == "--uninstall" ]]; then
  set_default "$HOME/.claude/CLAUDE.md" "$HOME/.claude/skills/ferret-mode/SKILL.md"
  set_default "$HOME/.codex/AGENTS.md" "$HOME/.codex/skills/ferret-mode/SKILL.md"
fi
