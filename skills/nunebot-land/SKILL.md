---
name: nunebot-land
description: Merge a ready pull request once CI is green, watch it deploy, check production, and clean up the branch. Use only when I name it.
---

# nunebot-land

Take a pull request from open to merged, deployed, and checked in production. Arguments can name one or more PRs by number or URL. Without one, use the current branch's PR. With several, land them one at a time in the order given.

Naming this skill is my OK to merge and deploy. It is not my OK to roll back, run data migrations or backfills, change feature flags, or touch production data. Ask for those.

## 1. Check it's ready

Run `gh pr view <pr> --json number,url,title,state,isDraft,mergeable,mergeStateStatus,reviewDecision,headRefName,headRefOid,baseRefName,body,statusCheckRollup`.

- **CI still running:** wait with `gh pr checks <pr> --watch`, then continue.
- **CI red, conflicts, draft, or changes requested:** stop and tell me what's blocking. Don't fix it here.
- **Unresolved review threads:** stop and list them.
- **Review:** read `$(git rev-parse --git-dir)/nunebot-review.md` if this worktree has one for this branch. If its status isn't `DONE`, or its `Head` isn't the PR's head commit, say which commits weren't reviewed and ask before merging. If there's no ledger, say so and ask.
- **`## John: before merge`:** if the PR body has unchecked items there, show them and ask whether they're done.

## 2. Merge

Check the repo's settings with `gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed,deleteBranchOnMerge` and how recent PRs were merged, and use the same method. Merge with `gh pr merge <pr> --squash` (or `--merge`/`--rebase` to match).

Never pass `--delete-branch` and never check out the default branch: this may be a linked worktree, and `gh` would switch it to `main`. Delete the remote branch yourself in step 5.

## 3. Watch the deploy

Use the deploy map in the **Deploys** paragraph of `~/github/brain/nunebot/PROMPT.md` when it's there. Otherwise work it out from the repo (`app.json`/Heroku GitHub integration, `.github/workflows`, `fly.toml`, `config/deploy.yml` for Kamal, Workers Builds).

- **Heroku auto-deploy:** poll `heroku releases --app <app> -n 3` until a release for the merge commit appears, then wait for preboot (about 3 minutes) before checking. Never run `heroku config` or `heroku releases:info`.
- **GitHub Actions deploy:** find the run for the merge commit and `gh run watch` it.
- **Cloudflare Workers Builds:** watch the production `Workers Builds` check on the merge commit. Never run `wrangler deploy` or `script/deploy` there.
- **Manual (`fly deploy`, `kamal deploy`):** run the repo's deploy command from a clean checkout of the merge commit, in a worktree, never in my main checkout.
- **Gems and libraries:** there's no deploy. Stop after the merge and say whether a release looks due. Releasing is a separate ask.

If the deploy fails, stop and report the failing step and its output.

## 4. Check production

Pick checks that would catch this change breaking, and keep them read-only:

- Request the pages, endpoints, or health check (`/up`) the change touches, and confirm they succeed.
- Look for new Honeybadger faults since the deploy, and compare error rate and latency in Flare with the hour before.
- Do the checks listed under `## John: after merge/deploy` that you can, and tick them in the PR body. Leave the rest for me.

If something regressed, show the evidence, give the exact rollback command, and ask. Don't roll back on your own.

## 5. Clean up

- Delete the remote branch with `git push origin --delete <branch>` if GitHub didn't already.
- If brain's `john.md` lists steps for this PR that are now done, remove them, and commit and push brain by explicit path.
- Remove the worktree only if it isn't the one you're running in. Never delete a local branch with unpushed commits.

## 6. Report

```
Landed: <PR link>, <merge method>
Deployed: <release or run link, or "no deploy">
Production: <what you checked and what you saw>
John: <steps left for me, or "nothing">
```

Then say whether this session is safe to archive.
