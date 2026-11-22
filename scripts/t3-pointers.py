#!/usr/bin/env python3
"""Adds the T3 adapter pointer to every skill that uses Cursor mechanics.

The list mirrors the skills that upstream's generated Claude Code tree gives an
adapter pointer (cursor/plugins harness/pstack/claude-code). The core skills
(poteto-mode, arena, interrogate, swarm, setup-pstack) name T3 tools directly
and already carry their own pointer. Safe to run again: a skill that already
has the line is left alone. Run after merging upstream changes.
Usage: python3 scripts/t3-pointers.py [--check]"""
import pathlib, sys

LINE = ("In T3 Code, read [the T3 adapter](../poteto-mode/t3.md) once per session "
        "before you follow this skill. It maps the Cursor names in pstack skills to T3's tools.")
SKILLS = ["architect", "automate-me", "create-formal-verification-skill", "create-verification-skill",
          "figure-it-out", "how", "maintain-formal-verification-skill", "maintain-verification-skill",
          "make-bot-ui", "no-comments", "poteto-help", "principle-type-system-discipline", "recall",
          "reflect", "show-me-your-work", "teach", "technical-writing"]
CORE = ["poteto-mode", "arena", "interrogate", "swarm", "setup-pstack"]

root = pathlib.Path(__file__).resolve().parent.parent / "skills"
check = "--check" in sys.argv
missing = []
for name in SKILLS:
    f = root / name / "SKILL.md"
    text = f.read_text()
    if "../poteto-mode/t3.md" in text:
        continue
    if check:
        missing.append(name); continue
    lines = text.split("\n")
    h1 = next(i for i, l in enumerate(lines) if l.startswith("# "))
    lines[h1 + 1:h1 + 1] = ["", LINE]
    f.write_text("\n".join(lines))
    print(f"added pointer: {name}")
for name in CORE:
    if "t3.md" not in (root / name / "SKILL.md").read_text():
        missing.append(name)
if missing:
    print("missing T3 pointer:", ", ".join(missing)); sys.exit(1)
print("ok: every skill that uses Cursor mechanics points to t3.md")
