---
name: arena
description: "Spawn N parallel candidates at the same task, pick a base, graft the strongest parts of the losers into it. Use for /arena, 'arena this', 'throw it in the arena', or when one attempt at a non-trivial artifact would lock in the wrong shape."
disable-model-invocation: true
---

# Arena

Read [t3.md](../poteto-mode/t3.md) once per session before you start agents. It covers `delegate_task`, waiting, worktrees, and models.

Open a todo list with one entry per phase (Frame, Fan out, Cross-judge, Pick, Graft, Verify) before launching anything. With no todo tool, keep it as a numbered list in your reply.

## Phase A: Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. State the artifact each candidate is producing.
2. Derive the rubric, 3-6 concrete gradeable criteria for what success looks like on *this* task. It is the picker's tool in Phase D. Candidates only see the task.
3. Pick the runners from the `arena runners` line in `~/.config/ferret-stack/models.md`, by default `claudeAgent/claude-fable-5-2 effort=high`, `codex/gpt-6-luna reasoningEffort=high`, and `antigravity/gemini-4-neon thought_level=xhigh`. An `auto` or `inherit-parent` entry is the parent model, so omit `target`. Check each runner against `orchestrator_capabilities`. If a provider is disabled or `delegate_task` rejects a target, use the nearest listed model of the same family or drop the seat, keep at least two runners from different vendors, and say so. Families go by model id prefix, and the longest match wins: `claude-fable-*`, `claude-*`, `gemini-*`, and `gpt-*`. Any other model's family is its text before the first hyphen. Spawn more for multiple design directions, and repeat one model when the work is generation-bound, not judgment-sensitive. Panel seats keep the reasoning level in their line or default. Pick any other subagent's level per the Subagents section of the **poteto-mode** skill.
4. Give each candidate its own output location, per the **separate-before-serializing-shared-state** principle skill. For anything in a git repo, that is `isolation: "worktree"`, and the candidate commits on its own branch (t3.md, Worktrees). Otherwise it is `/tmp/arena-<slug>/candidate-<n>/` with `isolation: "shared"`.

## Phase B: Fan out

Spawn all N subagents in one message: N `delegate_task` calls with `mode: "async"`, `role: "design"` (or `"implementation"` for code), and a `title` of `arena <slug>: candidate <n>`. Each `task` opens with `Read <poteto-mode>/worker.md before anything else.`, then gives the task, the path to the shared grounding, its own output location, and instructions to produce the artifact and a short rationale naming the alternatives it considered and what it rejected. A worktree candidate also reports its worktree path, branch, and commit SHA. Do not poll. Each completion wakes you, and Phase C starts on the last one.

If a candidate produces no output, proceed with N-1 and note the dropout.

## Phase C: Cross-judge

After all Phase B candidates complete, spawn one read-only judge (`delegate_task`, `role: "review"`, a brief that says read-only) from the `arena cross-judge pool` line in `~/.config/ferret-stack/models.md`, by default `codex/gpt-6-luna reasoningEffort=high`, `antigravity/gemini-4-neon thought_level=xhigh`, `claudeAgent/claude-opus-5-5 effort=high`. The judge is never from the parent's vendor. Vendor comes from the model id (t3.md, Models), and Fable counts as Claude for that check, so use the first entry from another vendor. Your own model is in `orchestrator_capabilities` as the inherited model. An `auto` or `inherit-parent` entry is the parent model, so it never judges. If `delegate_task` rejects a target, use the nearest listed model of the same family, then the next such entry, or skip the judge, and say so. While you read in Phase D, the judge scores each candidate, by path label, on each rubric criterion and recommends a base.

## Phase D: Pick a base

Read every candidate end to end before picking. Score each against the rubric criterion by criterion, not on holistic feel, and compare with the cross-judge when Phase C ran one. Agreement on the base confirms the pick. Disagreement means one of you is biased or the rubric was ambiguous. Read both rationales before deciding.

Pick the base a future maintainer can extend most easily without breaking invariants. When two feel tied, prefer the cleaner boundary or smaller API, per the Laziness Protocol.

## Phase E: Graft

Walk each losing candidate once more for what is worth porting into the base, usually one or two things per candidate, not most of it. Fold each graft in by hand, per the **redesign-from-first-principles** principle skill, so the result stays coherent under one mental model. Don't paste mechanically.

If the candidates converge on one shape, that is strong agreement. Note it and ship the consensus shape. No graft is needed. If they wildly diverge, Phase A was under-specified. Reframe and re-run rather than averaging the divergence.

## Phase F: Verify

Verify the synthesized artifact like any other output, per the **prove-it-works** principle skill. If verification finds a problem the arena missed, either Phase A was wrong (re-frame and re-run) or a candidate caught it and you missed the graft (go back to Phase E). Don't paper over it.

## Outputs

One synthesized artifact, with a short synthesis note alongside naming the base and why, the cross-judge's verdict or that Phase C skipped the judge, each graft with its source candidate, what was rejected and why, any convergence or dropouts, and the verification result.
