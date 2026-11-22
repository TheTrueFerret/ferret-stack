# Set up Ferret Stack

In this page you install the skills, pick which models Ferret Stack uses, and run your first task. Setup is one script plus a short conversation.

## Install the skills

Clone the repository, then run its install script with `--default`:

```text
git clone https://github.com/TheTrueFerret/ferret-stack.git ~/coding-projects/ferret-stack
~/coding-projects/ferret-stack/scripts/install.sh --default
```

The script links every skill into `~/.claude/skills` and `~/.codex/skills`, and the two agents into `~/.claude/agents`. Claude Code and Codex threads in T3 Code both find the skills from there. The script is safe to run again, and it skips any path where something else already sits. `--default` also adds a marked block to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`, so a request to change something runs in ferret mode without typing `/ferret-mode`, while questions and chat are answered normally. Leave it off if you only want the slash command. To remove the stack, run `scripts/install.sh --uninstall`. It deletes only its own links and that block.

Because the skills are links, a `git pull` in the repository updates them everywhere at once.

## Pick your models

Open a T3 thread and run:

```text
/setup-ferret-stack
```

[`/setup-ferret-stack`](../../skills/setup-ferret-stack/SKILL.md) reads `orchestrator_capabilities` to see which providers and models your T3 Code can run, asks for a reasoning budget, shows you each role (code delegates, judgment, the review panels), and asks what you want. Answer the questions. It writes `~/.config/ferret-stack/models.md`, a small file every Ferret Stack skill reads before it starts a helper. Each line is one role, in the form `provider/model option=value`, such as `claudeAgent/claude-opus-5-5 effort=xhigh`.

The defaults are the same as the `large` budget. Code, prose, and judgment run on Claude Opus 5.5 at `xhigh` effort. Mechanical edits run on Claude Sonnet 5.5. Verification and swarm workers run on Opus 5.5 at `high`. The review panels for `/arena` and `/interrogate` seat three vendors: Claude Fable 5.2, GPT-6 Luna on Codex, and Gemini 4 Neon on Antigravity. No role runs above `xhigh`. Outside a review panel, Fable 5.2 runs only when you name it for a task or after two Opus 5.5 runs of the same brief fail their check. `medium` lowers each role one level and `small` lowers it two, and both spend fewer tokens.

A provider can be enabled and still fail to start, for example when you haven't signed in to it. Ferret Stack retries that seat once. If it fails again, Ferret Stack drops the provider for the rest of the session, tells you which one and why, and keeps at least two vendors on every panel. Signing in is yours to do.

You only override what you care about. A role with no line in the file keeps the skill's default. To restore a default, delete that role's line. A rerun of `/setup-ferret-stack` keeps any role whose model differs from the default. When a default changes, a file written before the change still pins the old default until you run `/setup-ferret-stack` again. That run replaces the old defaults it recognizes, tells you which, and keeps your other choices. To drop a pin it does not recognize, delete that role's line or the file first.

You might be wondering what happens if you'd rather not pick. Set a role to `inherit-parent` or `auto` and Ferret Stack starts that helper with no model target, so it runs on the model of the thread you typed in. Both values mean the same thing, and neither is a model name. For a panel role the value is a list, and one helper runs per entry, so the list length sets the panel size. Setup also configures `swarm workers`, the default model for every `/swarm` worker unless a race names a model for each arm.

## Accept the verification offers, or don't

At the end of setup, `/setup-ferret-stack` looks for a way to prove app behavior in your project, either a `verify-*` skill or an existing harness. If it finds neither, it offers once to generate one with [`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md).

Say yes and it writes `.claude/skills/verify-<app>/`, with a link at `.agents/skills/verify-<app>` so Codex threads find it too. It's a project-local skill that teaches agents to drive your app the way a user does. It proves the skill works once before handing it over. Say no and setup moves on. You can run `/create-verification-skill` yourself any time. [Verify and ship](./06-verify-and-ship.md#create-a-project-verification-skill) covers it in depth.

If you're new to Ferret Stack, say yes. An agent that can check its own work keeps going until the check passes. An agent that can't hands every result back to you to check by hand. Of everything in this guide, the verification skill pays off the most.

Then setup offers once to generate a formal verification skill with [`/create-formal-verification-skill`](../../skills/create-formal-verification-skill/SKILL.md), unless the project already has one. Tests check the cases someone thought to write. A formal verification skill checks one key property of your code, such as "a job never runs twice at once", in every case within a stated scope. Say yes when your code has concurrency, retries, a state machine, or a parser, where a bug is costly and tests rarely reach the case that breaks. Otherwise say no, and run it later if that changes. [Verify and ship](./06-verify-and-ship.md#prove-a-property-with-a-formal-verification-skill) covers it.

After setup, start a new thread. Ferret Stack reads the models file once per session, before its first helper.

## Keep the cost in check

Ferret Stack spends extra tokens on helpers and review panels. That's the price of the rigor. To spend fewer:

- Rerun `/setup-ferret-stack` and pick a smaller reasoning budget or cheaper models. A strong model in the thread you type in with cheaper, faster models in the code roles is a good split.
- Set a role to `auto` or `inherit-parent` so it runs on the thread's own model.
- Shorten a panel list. Each entry runs one helper.
- Save `/ferret-mode` for work that needs rigor. A small, obvious edit doesn't.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
/ferret-mode add a --json flag to this command. text output stays byte-identical. verify both.
```

In a Codex thread, type `$ferret-mode` instead. Every skill in this guide works the same way, with `$` in place of `/`.

Watch the todo list. Its first items are the matched playbook's steps copied in, the Feature playbook for this prompt. When a thread has no todo tool, the list shows up numbered in the reply instead, and the agent restates it with marks at each phase.

The thread you type in is the lead. It plans, reads results, and talks to you. When a step needs a helper, the lead starts one with T3's `delegate_task`, and you see it appear as its own child thread. The lead doesn't sit and poll. When a helper finishes, its report arrives in the lead thread as a wake-up, and the lead picks up from there.

From here you can type normal follow-ups. The skill stays in the thread's context, so short follow-ups keep its rules. It fades as a long thread moves on, so start each new task with `/ferret-mode` again. To make it the default in every session, add a line such as "use /ferret-mode for multi-step tasks" to `CLAUDE.md` for Claude threads or `AGENTS.md` for Codex threads.

Next: [Route work through `/ferret-mode`](./02-ferret-mode.md).
