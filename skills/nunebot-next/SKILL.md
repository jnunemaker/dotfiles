---
name: nunebot-next
description: Tell me the single next step for the work in this session and any decisions only I can make. Use only when I name it.
---

# nunebot-next

I'm asking "what's next?" Give me one step, not a plan. Arguments, if any, narrow what I'm asking about, such as `/nunebot-next rollout`.

Don't change anything while answering: no commits, pushes, merges, deploys, or edits. Reading is fine.

## 1. Work out where things stand

Start from this conversation: what I asked for, what's done, and what's still open. Then check the parts that drift, because I may have committed, merged, or deployed since you last looked:

- `git status --short`, the current branch, and whether it's pushed.
- `gh pr view --json number,url,state,isDraft,mergeable,reviewDecision,statusCheckRollup` for this branch's PR, if there is one.
- `$(git rev-parse --git-dir)/nunebot-review.md`, if it exists, for the review status and any open findings. Compare its `Head` with the branch's latest commit, so you can say which of simplify, QA, cross-model review, and review of the fixes actually ran on what's there now.
- Unresolved review comments on the PR.
- After a merge: whether it deployed, and what's left to turn on or check in production, like a feature flag, a backfill, or a gem release.

If this conversation has no work in it yet, look at my open PRs in this repo (`gh pr list --author @me`) and this repo's worktrees with unmerged branches, and tell me which one to pick up.

## 2. Pick the one next step

My usual path is: build, `/nunebot-review`, `/nunebot-pr`, CI and review, `/nunebot-land` (merge, deploy, check production, clean up), roll out any flag. Find the first thing on that path that isn't done, or the next step of whatever else we're doing, like a manual setup I'm walking through.

When everything's done, the next step is archiving this session. Say so.

Say who does it. If it's me, give the exact command, link, or click. If you can do it, say so.

## 3. Find my decisions

Only list decisions that block the next step or change it, and only ones you can't make from the code, the conversation, or a sensible default. For each, give the options in a few words and say which you'd pick and why in one clause. If there are none, say so.

## 4. Answer

Use this shape and nothing else:

```
Where: <one line on where things stand>
Reviewed: <what ran on the latest commit, and what didn't>
Next: <the one step, who does it, and the command or link>
Decide: <each blocking decision with your pick, or "nothing">
```

Leave out `Reviewed` when there's no branch. Keep each line short. Don't add a list of later steps, a recap, or caveats that don't change what I do. If I ask "then what?", give me the step after that the same way.

If the next step is yours, end by asking whether to do it. If your tool has a way to ask a question with buttons, use it for the go-ahead or the decision.
