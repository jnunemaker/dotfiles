---
name: nunebot-land
description: Merge a ready pull request once CI is green, watch it deploy, check production, and clean up the branch. Use only when I name it.
---

# nunebot-land

Take a pull request from open to merged, deployed, and checked in production. Arguments can name one or more PRs by number or URL. Without one, use the current branch's PR. With several, land them one at a time in the order given.

Naming this skill is my OK to merge and deploy. It is not my OK to roll back, run data migrations or backfills, change feature flags, or touch production data. Ask for those. Never release a gem or package, push a version tag, or bump a version.

## 1. Check it's ready

Run `gh pr view <pr> --json number,url,state,isDraft,mergeable,reviewDecision,headRefName,headRefOid,baseRefName,body` and `gh pr checks <pr>`.

- **CI still running:** wait with `gh pr checks <pr> --watch`, then continue. "No checks reported" means the repo has no CI, which isn't a blocker.
- **CI red, conflicts, draft, or changes requested:** stop and tell me what's blocking. Don't fix it here.
- **Unresolved review threads:** stop and list them.
- **Review:** find the worktree that has the PR's head branch checked out (`git worktree list`). No worktree means no ledger. Otherwise check that worktree's nunebot-review ledger the way `nunebot-pr` step 2 does, using that worktree's `HEAD`. If it isn't `DONE`, or its `Head` isn't the PR's head commit, say which commits weren't reviewed and ask before merging. If there's no ledger, say so and ask.
- **`## John: before merge`:** if the PR body has unchecked items there, show them and ask whether they're done.

## 2. Merge

Use the merge method the repo allows (`gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed`). If it allows more than one, match how recent PRs were merged. Pass `--match-head-commit <headRefOid>` from step 1, so a push after your checks stops the merge. Delete the remote branch yourself in step 5.

## 3. Watch the deploy

Find how this repo deploys in the Deploys paragraph of brain's Nunebot prompt (`grep -m1 '^Deploys' ~/github/brain/nunebot/PROMPT.md`) and follow its repo rules. If it doesn't cover this repo, work it out from the repo (`app.json` or the Heroku GitHub integration, `.github/workflows`, `fly.toml`, Kamal's `config/deploy.yml`, Workers Builds).

- **Heroku auto-deploy:** wait in one blocking command for the merge commit's release to finish. Heroku shows 8-character SHAs, so match on the first 7 (`git rev-parse --short=7 <merge-sha>`), and give up after about 20 minutes: `for i in $(seq 40); do line=$(heroku releases --app <app> -n 5 | grep "Deploy <sha7>"); case "$line" in ""|*pending*|*executing*) sleep 30 ;; *) break ;; esac; done; echo "${line:-no release}"`. Continue only when the line shows a finished release. If it printed `no release`, or the line still says `pending` or `executing`, or says `failed`, stop and report it. Otherwise wait out preboot (`sleep 180`).
- **GitHub Actions deploy:** find the run for the merge commit and `gh run watch` it.
- **Cloudflare Workers Builds:** watch the production `Workers Builds` check on the merge commit.
- **Manual (`fly deploy`, `kamal deploy`):** run the repo's deploy command from a worktree at the merge commit.
- **Gems and libraries:** there's no deploy. Stop after the merge.

If the deploy fails, stop and report the failing step and its output.

## 4. Check production

Pick checks that would catch this change breaking, and keep them read-only:

- Request the pages, endpoints, or health check (`/up`) the change touches, and confirm they succeed.
- Look for new Honeybadger faults since the deploy, and compare error rate and latency in Flare with the hour before.
- Do the checks listed under `## John: after merge/deploy` that you can, and tick them in the PR body. Leave the rest for me.

If something regressed, show the evidence, give the exact rollback command, and ask.

## 5. Clean up

- Delete the remote branch with `git push origin --delete <branch>` if GitHub didn't already.
- If brain's `john.md` lists steps for this PR that are now done, remove them, and commit and push brain by explicit path.
- Remove the worktree only if it isn't the one you're running in. Never delete a local branch with unpushed commits.

## 6. Report

Use this Markdown list, not a code block:

- **Landed:** the PR link and merge method.
- **Deployed:** the release or run link, or "no deploy".
- **Production:** what you checked and what you saw.
- **John:** steps left for me, or "nothing".

Then say whether this session is safe to archive.
