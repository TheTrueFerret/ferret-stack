### Opening a PR

Invoked at the end of every other playbook.

Work from a git worktree off trunk, with one topic per PR (Non-negotiables). Rebase into small, landable commits. Before commit, reread the diff and delete what the change does not need (Laziness Protocol).

Title: `type(scope): subject`, naming a real symbol when one carries the change. Body: a one-minute briefing under 40 lines with these `##` headings in order, dropping empty ones: `## Why`, `## What changed`, `## Scope`, `## Tradeoffs` (only rejected alternatives a reviewer would otherwise ask about), `## Blast Radius`, `## Verification`.

Stack follow-ups by base branch. Open PRs ready, with `gh pr create` and no `--draft`, then call `link_pull_request` with the PR's URL. Opening a PR does not start a babysit.
