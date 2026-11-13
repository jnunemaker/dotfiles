---
name: nunebot-pr
description: Commit what's left, push the current branch, and create or update its pull request in my PR format, using the nunebot-review ledger when there is one. Use only when I name it.
---

# nunebot-pr

Get the current branch into a pull request I can merge after reading the body. Read top to bottom, the body should build confidence.

Never merge, deploy, enable feature flags, or change anything in production. Never run `git stash`. Don't add a `nunebot` label unless I or the prompt calling this asks for it.

## 1. Get the branch ready

- If you're on the default branch, create `nunes/<short-description>` first.
- Commit uncommitted work that belongs to the change. Leave anything unrelated unstaged and mention it.
- Check `git diff --stat origin/<base>...HEAD` and remove any file the change doesn't need, such as schema dumps without a migration, lockfiles, or generated assets.
- Never commit secrets, customer data, or screenshots.

## 2. Read the ledger

Read `$(git rev-parse --show-toplevel)/.nunebot/review.md` if it exists, otherwise `$(git rev-parse --git-dir)/nunebot-review.md`, where older reviews left it. Worktrees get reused, so first check that it belongs to this change: its `Branch` must be the current branch, its `Base` must be this PR's base, `git merge-base --is-ancestor <Head> HEAD` must succeed, and `git merge-base --is-ancestor <Head> origin/<base>` must fail, because a `Head` already in the base means that work merged in an earlier PR. If any check fails, including after a rebase, treat it as no ledger and say which check failed. Never carry its review or proof into the PR.

- **`GAVE_UP` or `BLOCKED`:** don't open a PR. Push the branch and report the open findings, unless I told you to open it anyway. If I did, put the open findings in the Review section.
- **`Head` isn't the current commit:** list the newer commits in the Review section as not reviewed.
- **No ledger:** don't suggest a review happened. The Review section says `/nunebot-review` was not run, and Proof holds only what you can actually show now.

## 3. Check what the PR may say

Run `gh repo view --json visibility -q .visibility`. In a public repo, never describe a vulnerability in the PR, commits, or branch name. If this change fixes one, stop and tell me instead of pushing.

## 4. Push

Push with `git push -u origin HEAD`. If the remote moved, fetch and rebase your branch, push again, and repeat the ledger checks from step 2. Use `--force-with-lease` only on a branch you created.

## 5. Write the body

Write it to a temporary file outside the repo, using these sections in this order. Keep it concise and leave out sections that don't apply. If the repo has a PR template, keep its required parts and use these sections for the rest.

```markdown
## John: before merge
- [ ] Steps only I can do first, such as a production check.

## John: after merge/deploy
- [ ] Deploy steps, purges.

## Why
The problem, with a link to its evidence.

## What changed
**Size:** code +120 −30 · tests +366 · docs +14

## Proof
Failing then passing output, focused test results, seen running, numbers. Show the real output.

## Performance & compatibility
What it costs at runtime, and whether it's mostly additive.

## Review
What /simplify trimmed, what /qa found, what the security review found, and each cross-model review round: findings fixed, findings rejected and why.

## Risk and rollback
```

Start What changed with the line printed by `<this skill's directory>/line-counts origin/<base>`, as is. It counts lines added and removed against the base, by kind: code, tests, docs, migrations, config & tooling (CI, scripts, Gemfile, YAML), generated (lockfiles, schema dumps, vendored or minified files) and assets (files only). Run it again after every push, so it matches the final diff. If a file lands in the wrong kind, `--files` shows how each was counted; fix the patterns in the script rather than editing the line by hand.

The John sections are only for changes you can't make yourself and production checks. If you can do it, do it instead of listing it. If an app doesn't deploy on merge, list the deploy step under `John: after merge/deploy`. Gem releases, Go tags and `workspace update` can happen later, so they aren't John steps: leave them out of the John sections.

## 6. Create or update the PR

Check for an existing PR with `gh pr view --json url,state`. Treat a closed or merged one as no PR.

- **New:** `gh pr create --base <base> --title "<title>" --body-file <file>`, ready for review, not a draft. The title is short and says what changed. Link an issue with `Fixes #123` when there is one.
- **Existing:** `gh pr edit --title "<title>" --body-file <file>`.
- **Screenshots:** attach each image from the ledger with `--attach './after.png#alt text'` on `gh pr create` or `gh pr edit`. This needs gh 2.99 or newer. `--body-file` drops images already attached, so after editing a body, attach them again.
- **`needs-john`:** only when the PR is blocked on me: a decision only I can make, or something only I can run before it can merge. Add the label, creating it if it's missing, and remove it once nothing is blocked. Steps for after merge or deploy never earn it, and neither does a pending gem release or Go tag.
- **Labels I or the caller asked for:** add them, creating them if they're missing.

## 7. Report

Give the PR URL and say whether it was created or updated. Don't wait on CI. Report any John steps.
