---
name: setup-pstack
description: Configure which models pstack uses per role and at what reasoning budget. Detects your available models in T3 Code and writes a models file that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

# Setup pstack

Write `~/.config/ferret-stack/models.md`, the file that sets pstack's model per role. Every pstack skill reads it before it starts an agent. The target format is in [the T3 adapter](../poteto-mode/t3.md), section Models.

## Steps

### 1. Detect available models

Call `orchestrator_capabilities` (a `t3-code` MCP tool, which may need loading first). That is the dependable source. A provider is usable when it is not disabled and `canRunChildTask` is true. Each usable provider lists its models, and each model lists its option id (`effort`, `reasoningEffort`, or `thought_level`) and allowed values. A model the short list omits can be found with its `search` parameter. Outside T3, ask the user to paste the models they have. Never write a target you have not confirmed is available. The aliases `inherit-parent` and `auto` are always valid even though they are not detected models.

### 2. Load current state

The default role-to-model mapping is the file shape shown in step 5 below. If `~/.config/ferret-stack/models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5 is from a retired role. Drop it, and tell the user.

If the user has an old Cursor rule at `~/.cursor/rules/pstack-models.mdc` and no models file yet, map each of its slugs with the table in t3.md (Models), and treat the result as the current choices.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer `AskUserQuestion` over free text. Offer these three options with these exact labels, and name the current budget when the file records one. With no file, say that `large` matches the skill defaults.

- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) Apply it.** Build the working table from the skill defaults, and on a re-run keep any role you changed by family, list, or alias (`inherit-parent`, `auto`). Families are the ones Phase A of the **arena** skill defines, so Fable is its own family. Each role has a target effort, which is its default's effort moved by the budget. `large` keeps it, `medium` lowers it one step, and `small` lowers it two steps, on the ladder `xhigh` > `high` > `medium` > `low`. No role runs above `xhigh`, and a target at the bottom of the ladder stays there. Set the effort value of every real target in the role, panel entries included, to the role's target effort, using that model's own option id. If the model does not allow that value, use its highest allowed value at or below the target, else mark the role as needing a choice. `inherit-parent` and `auto` do not change. So `medium` turns `claudeAgent/claude-opus-5-5 effort=xhigh` into `effort=high`, and `antigravity/gemini-4-neon thought_level=xhigh` into `thought_level=high`. Fast mode is never written unless the user asks for it.

**(c) Show the roles and confirm.** Show every role with its model, marking any target not in the detected set as needing a choice. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the detected models at `xhigh` or below plus `inherit-parent` and `auto` (both mean: this role runs on the parent chat model) as the options. Prefer `AskUserQuestion` over free text. For panel roles (arena runners, interrogate reviewers) the value is a list, and one subagent runs per entry, alias entries included, so the list length sets the count. A panel should mix vendors, so name the vendor of each entry (t3.md, Models). `arena cross-judge pool` is also a list, but Arena runs one judge. It tries only values from a vendor other than the parent's, in list order, so order it by preference. Fable and the other Claude models are one vendor. An `inherit-parent` or `auto` value never judges. `swarm workers` is the default model for every worker and for verification, unless a race or comparison assigns another model per arm.

### 4. Validate

Every real target written must be in the detected set, on an enabled provider, with an option value that model allows, at `xhigh` or below. `inherit-parent` and `auto` always pass. If a chosen target is not available, stop and ask again.

### 5. Write the file

Create `~/.config/ferret-stack/` if needed, and write `models.md` with the comment lines, the `# defaults: t3-1` line, a `# budget` line with the chosen label and the effort that label names, and one line per role, using the same labels poteto-mode uses. Overwrite the whole file so re-runs stay idempotent. Shape:

```
# pstack model configuration for T3 Code. One line per role. Delete a line to fall back to the skill default.
# A value is <providerInstanceId>/<model id> <option id>=<value>, or a comma-separated list of them.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit `target` in delegate_task). Alias entries in a panel list still count toward its fan-out.
# defaults: t3-1
# budget: large (xhigh)
feature, refactoring: claudeAgent/claude-opus-5-5 effort=xhigh
bug-fix: claudeAgent/claude-opus-5-5 effort=xhigh
perf-issue: claudeAgent/claude-opus-5-5 effort=xhigh
hillclimb: claudeAgent/claude-opus-5-5 effort=xhigh
judgment and prose: claudeAgent/claude-opus-5-5 effort=xhigh
mechanical edits: claudeAgent/claude-sonnet-5-5 effort=medium
arena runners: claudeAgent/claude-fable-5-2 effort=high, codex/gpt-6-luna reasoningEffort=high, antigravity/gemini-4-neon thought_level=xhigh
arena cross-judge pool: codex/gpt-6-luna reasoningEffort=high, antigravity/gemini-4-neon thought_level=xhigh, claudeAgent/claude-opus-5-5 effort=high
swarm workers: claudeAgent/claude-opus-5-5 effort=high
interrogate reviewers: claudeAgent/claude-fable-5-2 effort=high, codex/gpt-6-luna reasoningEffort=high, antigravity/gemini-4-neon thought_level=xhigh
```

### 6. Confirm

Tell the user the file was written and that every new pstack run reads it. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.

### 8. Offer a formal verification skill (optional)

Check whether the project already has a formal verification skill (a project skill that runs a model checker, a proof, or another verifier against the code). If not, offer once: "want a formal verification skill, so agents can prove a key property of your code holds in every case in scope, not only the cases tests reach? I can generate one with /create-formal-verification-skill." On yes, invoke `/create-formal-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.
