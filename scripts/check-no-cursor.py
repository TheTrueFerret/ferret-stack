#!/usr/bin/env python3
"""Fails if Cursor-specific names or mechanics, or pstack's old names, appear in the stack.

The stack started as poteto's pstack, written for Cursor. Everything now names
T3 Code, Claude Code, or Codex tools directly. Run this after any edit, and
after merging upstream changes: it prints every hit with file:line.
Usage: python3 scripts/check-no-cursor.py"""
import pathlib, re, sys

PATTERNS = [
    (r"(?i)\bcursor\b(?!-?\s*(position|key|movement|blink))", "the word Cursor"),
    (r"`Task`|\bTask (tool|call|subagent)s?\b", "Cursor's Task tool (use delegate_task)"),
    (r"\bsubagent_type\b|\bgeneralPurpose\b", "Cursor subagent fields"),
    (r"\brun_in_background\b|\breadonly: ?(true|false)\b|environment: \"(cloud|local)\"|\bcloud_base_branch\b", "Cursor Task options"),
    (r"(?i)\bcloud agents?\b|\bProject workers?\b|\bagents window\b|\bcustom mode\b|option\+enter|alt\+enter", "Cursor features"),
    (r"(?<![\w-])/loop\b", "Cursor's /loop (use schedule_task)"),
    (r"\bAskQuestion\b|\btodolist\b", "Cursor tool names"),
    (r"(?i)\bbugbot\b", "Bugbot (use 'review bots')"),
    (r"\bcontrol-(ui|cli)\b|\bdeslop\b|cursor-team-kit", "cursor-team-kit skills"),
    (r"\.mdc\b|agent-transcripts|\bAutomations?\b|api2\.cursor", "Cursor files and automations"),
    (r"\bclaude-[a-z0-9-]+-(?:xhigh|high|medium|low)(?:-fast)?\b|\bgemini-4-neon-(?:xhigh|high|medium|low)\b|-fast\b`", "Cursor model slugs (use provider/model option=value)"),
    (r"\bpoteto-(agent|help|mode)\b|\bsetup-pstack\b", "pstack's old names (use ferret-agent, ferret-help, ferret-mode, setup-ferret-stack)"),
    (r"\bOrigin\b|`origin pr|command -v origin|origin pr ", "Cursor's Origin forge (use gh)"),
]
ALLOW_FILES = {"PLAN.md", "UPSTREAM", "LICENSE", "scripts/check-no-cursor.py"}
ALLOW_LINE = re.compile(r"github\.com/cursor/plugins|cursor/plugins@|originally (written )?for Cursor|check-no-cursor")
SKIP_DIRS = {".git", "node_modules"}
TEXT = {".md", ".sh", ".py", ".ts", ".json", ".yaml", ".yml", ".txt", ".tla", ".cfg"}

root = pathlib.Path(__file__).resolve().parent.parent
hits = 0
for f in sorted(root.rglob("*")):
    rel = f.relative_to(root).as_posix()
    if not f.is_file() or SKIP_DIRS & set(f.relative_to(root).parts) or rel in ALLOW_FILES:
        continue
    if f.suffix not in TEXT and f.name not in {"UPSTREAM"}:
        continue
    for n, line in enumerate(f.read_text(errors="ignore").splitlines(), 1):
        if ALLOW_LINE.search(line):
            continue
        for pat, why in PATTERNS:
            m = re.search(pat, line)
            if m:
                hits += 1
                print(f"{rel}:{n}: {why}: {m.group(0)!r}")
                break
print(f"{hits} Cursor hits" if hits else "ok: no Cursor names or mechanics left")
sys.exit(1 if hits else 0)
