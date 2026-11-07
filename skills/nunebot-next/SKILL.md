---
name: nunebot-next
description: Tell me the single next step for the work in this session and any decisions only I can make. Use only when I name it.
---

# nunebot-next

I'm asking "what's next?" Arguments, if any, narrow what I'm asking about, such as `rollout`.

Don't change anything while answering: no commits, pushes, merges, deploys, or edits. Reading is fine.

## 1. Work out where things stand

Start from this conversation: what I asked for, what's done, and what's still open. Then check the parts that drift, because I may have committed, merged, or deployed since you last looked. These are independent, so run them together:

- `git status -sb` for the branch, uncommitted work, and whether it's pushed.
- `gh pr view --json number,url,state,isDraft,mergeable,reviewDecision` and `gh pr checks` for this branch's PR, if there is one, plus its unresolved review comments.
- The nunebot-review ledger, checked the way `nunebot-pr` step 2 does, to say which review steps ran on the current head and which findings are open.
- After a merge: whether it deployed, and what's left to turn on or check in production, like a feature flag, a backfill, or a gem release.

If this conversation has no work in it yet, look at my open PRs in this repo (`gh pr list --author @me`) and branches with worktrees that aren't merged (`git worktree list` and `git branch --no-merged origin/<default>`), and tell me which one to pick up.

## 2. Pick the one next step

My usual path is: build, `nunebot-review`, `nunebot-pr`, CI and review, `nunebot-land`, roll out any flag. Find the first thing on that path that isn't done, or the next step of whatever else we're doing, like a manual setup I'm walking through. When everything's done, the next step is archiving this session.

When the next step is merging, check it's really ready: mergeable, CI green, no unresolved review threads, no unchecked `## John: before merge` items, every commit reviewed or named as unreviewed, and a PR body that covers every commit. Update an out-of-date body after asking, since this skill doesn't change anything.

If a review ran and only later commits weren't reviewed, the next step is reviewing just those commits (`codex review --commit <sha>` in Claude Code, or the `nunebot-review` step 5 prompt in Codex), not a full `/nunebot-review`. Suggest the full review only when those commits change behavior that no earlier review covered.

## 3. Find my decisions

Only list decisions that block the next step or change it, and only ones you can't make from the code, the conversation, or a sensible default.

## 4. Answer

Answer with a Markdown list in this order, and nothing else. Never use a code block.

- **Next:** the one step and who does it, then the exact command, link, or click in backticks.
- **Decide:** "nothing", or one numbered sub-bullet per decision, each ending with **Pick:** and your choice.
- **Status:** facts as short fragments joined with ` · `, such as the PR link, mergeable, CI, pushed.
- **Merge:** only when the next step is merging. ✅ ready, or ❌ with each blocker as a fragment.
- **Reviewed:** each review step as ✅ or ❌ with its name, joined with ` · `, then ❌ and the short SHA and subject of each commit made after the last review.

Write fragments, not sentences, and keep every line under about 12 words, so I can scan it in two seconds. Put any detail I need in a sub-bullet instead of a longer line. Link a PR as `owner/repo#123` and leave out its title. No later steps or recap.

For example:

- **Next:** I run `/nunebot-review` on this branch
- **Decide:**
  1. Full review of all 147 files before landing? **Pick:** yes, most were never cross-reviewed
- **Merge:** ❌ 2 commits unreviewed · PR body misses the test harness fix
- **Status:** boxoutsports/boxoutsports#5783 · mergeable · CI green · pushed
- **Reviewed:** ✅ Codex · ❌ nunebot-review · ❌ `a1b2c3d` Fix doc typo · ❌ `d4e5f6a` Fix test harness

Name a skill as `/name` in Claude Code and `$name` in Codex. Leave out `Reviewed` when there's no branch. If I ask "then what?", give me the step after that the same way. If the next step is yours, end with one short question asking whether to do it.
