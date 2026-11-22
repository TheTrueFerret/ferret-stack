# Ferret Stack plan (draft, edit anything)

Status: **approved 2026-11-22 with the recommended picks. Phases 1 and 2 done (commits 4ba4fa5, 2fe4996, 9ef9996). Phase 3 next.** Change, cross out, or add anything you
like. Answer the decisions in section 4 (write your pick after "Your pick:").
When you say go, I build only what this file says, one phase at a time, and
show you each phase before starting the next.

## 1. Goal (my understanding, so correct me)

Your own copy of poteto's **pstack**, working well in **T3 Code** in both
Claude and Codex threads, and using T3's tools for things like multi-model
panels and scheduled runs. Then customize it to how you work. New areas
(video, finance, Linker, notes) come later, and only once you design them.

## 2. What we are forking

pstack, from `cursor/plugins` (latest commit `7a58391`, 21 Nov 2026), MIT license.

| Part | Count | What it is |
|---|---|---|
| `poteto-mode` | 1 | The router. It reads your task, picks a playbook, and copies the steps into a todo list. It also holds the rules on what to do without asking. |
| Playbooks | 22 | Step-by-step recipes: bug fix, feature, perf, refactoring, prototype, babysit, shipping, autonomous run, and more. |
| Principle skills | 24 | One rule each, such as "smallest change", "prove it works", or "fix root causes". |
| Tool skills | 33 | `arena` and `interrogate` (several models on one task), `swarm`, `how`, `why`, `unslop`, `tdd`, `setup-pstack`, `recall`, `reflect`, and others. |
| Agents | 2 | `poteto-agent` (the helper wrapper) and `comment-sicko` (a comment reviewer). |
| Extras | | The `docs/guide`, and a "Benny" automation pack, which only runs in Cursor. |

## 3. Where pstack depends on Cursor (this is where T3 comes in)

| Cursor thing | Files | Becomes in T3 |
|---|---|---|
| The `Task` tool and `subagent_type` | 7 | Same-model helpers use the native subagent (`Agent` in Claude, `spawn_agent` in Codex). Other providers, background work, or separate checkouts use `delegate_task`. |
| Cursor model names, and `~/.cursor/rules/pstack-models.mdc` | 11 + 5 | A models file that maps each role to a T3 model, checked against `orchestrator_capabilities`. |
| Panels in `arena`, `interrogate`, and `swarm` | 3 | One `delegate_task` per provider. Enabled on your machine: Claude, Codex (GPT), and Gemini (Antigravity). Grok and Cursor are disabled. |
| Cloud agents (`environment: "cloud"`) | 4 | `delegate_task` with `isolation: "worktree"`, or a worktree thread. |
| `/loop` (keep working for hours) | 9 | `schedule_task`, or continuing within the turn. |
| Bugbot, and Cursor's PR tools | 8 | Treated as normal review comments. PR watching uses `watch_pull_request` or tstack's `babysit-pr`. |
| Mining agent transcripts (`recall`, `correct`, `automate-me`) | 9 | `t3_thread_search` and `t3_thread_read`, plus `~/.claude/projects` and Codex history files. |
| `control-ui` and `control-cli`, and `/deslop` (from another Cursor plugin) | 4 + 5 | T3's `preview_*` browser tools or Playwright. Bring `deslop` along, or drop it. |
| Cursor Automations (Benny pack) | 5 | `schedule_task` with a webhook, or drop it. |
| `AskQuestion` and the todo list | 3 + 6 | `AskUserQuestion` and `TodoWrite` in Claude, and `update_plan` in Codex. |

## 4. Decisions for you

**D1. How should the T3 changes be applied?**
- a) **Adapter file.** Keep poteto's files untouched, and add one `t3.md`
  that tells the agent "when a skill says X, do Y in T3". This is how pstack
  itself supports Claude Code. Pulling poteto's updates is easy. The cost is
  that the agent has to translate as it goes, which uses more tokens and is
  sometimes wrong.
- b) **Rewrite in place.** Edit every affected file (about 30) to name T3
  tools directly. This is the clearest for the agent, but each poteto update
  has to be merged by hand.
- c) **Mix (my pick).** Rewrite the core files in place (`poteto-mode`,
  `poteto-agent`, `arena`, `interrogate`, `swarm`, `setup-pstack`), and use
  the adapter for everything else.

Your pick: c) Mix (approved 2026-11-22). **Changed 2026-11-22 at your request:** all Cursor files and wording removed, so every file names T3, Claude Code, or Codex tools directly (option b). The guide is rewritten for T3. `scripts/check-no-cursor.py` keeps it that way.

**D2. Staying in sync with poteto's updates?**
- a) Copy once and own it from then on.
- b) **Record the upstream commit (my pick).** Same as how you vendor tstack
  in your dotfiles. Add a small script that shows what poteto changed since
  then, so we can merge it when you want.

Your pick: b) Record the upstream commit (approved). Since Cursor was removed, merging poteto's updates means hand-merging them into the rewritten text. `scripts/upstream-diff.sh` shows what changed.

**D3. Names?**
- a) Keep `poteto-mode`. The other skill names stay as poteto's.
- b) **Rename the router to `ferret-mode` (my pick).** Keep every other skill
  name, so pstack's docs still apply. Credit to poteto stays in the README and
  license.
- c) Rename everything.

Your pick: b) Rename router to `ferret-mode` (approved)

**D4. What to keep? (cross out what you don't want)**
- Keep: `poteto-mode` and its 22 playbooks, the 24 principles, `arena`,
  `interrogate`, `swarm`, `how`, `why`, `teach`, `unslop`, `bro`, `tdd`,
  `architect`, `blast-radius`, `reflect`, `correct`, `recall`, `ketchup`,
  `setup-pstack`, `poteto-help`, `figure-it-out`, `show-me-your-work`,
  `no-comments` and `comment-sicko`, `technical-writing`,
  `typescript-best-practices`, `benchmark-checklist`, `in-your-own-words`,
  `sharpen`, `automate-me`, `statechart`, the verification skills, and
  `ketchup-video`.
- Drop at first (my pick): the Benny automation pack (Cursor only), and
  `make-bot-ui` (built for Grok Bot webhooks).

Your changes: none, so drop Benny and `make-bot-ui` (approved). Done early, with the Cursor removal.

**D5. pstack and your tstack overlap on PRs. Which wins?**
pstack has its own babysit, shipping, and opening-a-PR playbooks. You already
use tstack's `full-send`, `full-stop`, `babysit-pr`, `file-pr`, `council`, and
`sol-loop`.
- a) **pstack's PR steps hand off to tstack (my pick).** One way of doing PRs.
- b) Keep pstack's own PR playbooks.
- c) Keep both, and you choose each time.

Your pick: a) Hand off to tstack (approved)

**D6. Default model per role** (you can change any of these later):

| Role | My pick |
|---|---|
| Code, judgment, writing | Claude Opus 5.5, xhigh |
| Simple mechanical edits | Claude Sonnet 5.5 |
| Panels (arena, interrogate) | Claude Fable 5.2 + GPT-6 Luna (Codex) + Gemini 4 Neon |
| Checking results | Claude Opus 5.5, high |

Your changes: none, so use the table as is (approved)

**D7. How to install?**
- a) **Symlinks from the repo into `~/.claude/skills` and `~/.codex/skills`
  (my pick).** Same as tstack. Skills keep their plain names.
- b) As a plugin (`/plugin install`). Commands get a prefix, such as
  `/ferret:ferret-mode`.

Your pick: a) Symlinks (approved)

**D8. Where does it live?** `~/coding-projects/ferret-stack`, with its own git
repo. Later on GitHub: private or public?

Your pick: `~/coding-projects/ferret-stack`. Private or public on GitHub: undecided, nothing is pushed yet.

## 5. Customizing (after T3 works, you choose)

Ideas only, not part of the build. Add your own:
- Your screenshot rule from `CLAUDE.md` (desktop and phone width for every UI
  change) built into the feature and bug-fix playbooks.
- PR format from tstack's `file-pr`.
- Your projects and setup (Omarchy, dotfiles, Linker) in a "your setup"
  section.
- Language: English only, or also Dutch?
- New areas (video, finance, Linker, notes): designed by you later. The
  archived first attempt is in `~/coding-projects/ferret-stack-v0` if you want
  to borrow anything, such as its tested video scripts.

Your ideas:

## 6. Phases (I stop after each one and show you)

1. **Fork as-is.** Copy pstack, record the upstream commit, install it, and
   check that it runs unchanged in a Claude thread and a Codex thread in T3.
   You see what works and what breaks before anything is changed.
2. **T3 layer.** Apply D1. Prove it with a real three-provider `arena` or
   `interrogate` run.
3. **Your customizations.** One at a time, from section 5.
4. **New areas.** Later, from your own design.

## 7. Your notes
