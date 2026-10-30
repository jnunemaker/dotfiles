---
name: nunebot-review
description: Run my full review loop on the current branch (simplify, QA, cross-model review of the change then only its fixes, performance and compatibility, proof). Use only when I name it. Pass "unattended" when nobody is watching.
---

# nunebot-review

Take the change on the current branch from written to proven, and leave a ledger for `nunebot-pr`.

This is a checklist. A nested skill returning does not end your turn: when one finishes, even with its own report or status block, go straight to the next step. You are done only after step 8.

If the arguments include `unattended`, nobody is watching. When a skill stops to ask a question, take its recommended option and record the choice in the ledger. Otherwise ask me.

Never run `git stash` (it's shared across worktrees), and never touch the default branch. The repo's `AGENTS.md` or `CLAUDE.md` wins over anything here, such as a rule not to run the full suite locally.

## 1. Set up

- Find the base branch: `gh pr view --json baseRefName -q .baseRefName`, otherwise the branch `origin/HEAD` points at. Fetch it.
- If you're on the default branch, create `nunes/<short-description>` first.
- Commit any uncommitted work that belongs to the change.
- If there's no diff against the base, report that and stop.
- Start the ledger fresh at `$(git rev-parse --git-dir)/nunebot-review.md`. Update it after every step, so it survives a compacted context. It stays out of the commit because it lives in the git directory.

## 2. Simplify

Use the `simplify` skill to shave the change down. Commit what it trims.

## 3. QA

Use the `qa` skill to actually use the thing and fix what's really broken. Commit the fixes.

## 4. Review by the other model

The other model reviews, so the author never grades its own work.

- **In Claude Code:** the `codex` skill, as `/codex review`.
- **In Codex:** the `claude-code` skill, as `/claude-code review`.

Decide on each finding: fix it if it's legitimate, reject it with a reason if it isn't. If nothing is legitimate, go to step 6.

## 5. Loop on the fixes only

Do at most 3 rounds of:

1. Commit the fixes as one commit and note its SHA.
2. Have the other model review only that commit, never the whole change again.
   - **In Claude Code:** `codex review --commit <sha>`.
   - **In Codex:** not `/claude-code review`, which always sends the whole branch. Write a temporary prompt file outside the repo asking for a review of this diff only, with findings labelled `[P1]`, `[P2]`, `[P3]` or `NO_FINDINGS`, followed by the output of `git show <sha>`. Then run `~/.codex/skills/gstack/bin/gstack-claude-code --user-invoked --cwd "$(git rev-parse --show-toplevel)" --access none --timeout-ms 600000 < <prompt-file>` and read `result` from the JSON it prints. If it fails, the review didn't happen, so the status is `BLOCKED`.
3. Decide on each finding as in step 4. If nothing is legitimate, go to step 6.

If the third review still has legitimate findings, stop. Commit nothing else, record the open findings, and go to step 8 with status `GAVE_UP`. Chasing zero findings is how small changes turn into 3,000 line PRs.

## 6. Performance and compatibility

Answer both from the final code, for someone who hasn't read it:

- **Performance:** what does this cost at runtime (queries, requests, hot paths, memory, job load)? Give before and after numbers for any claim that something got faster or cheaper. "No runtime impact" is a fine answer when it's true.
- **Compatibility:** is it mostly additive, checking more without breaking anything existing and legitimate? Name who or what could break, including stored data and API callers.

## 7. Prove it

On the final branch, gather every one of these that applies. Keep the actual output, not a description of it.

- **Failing, then passing:** a test that fails on the base branch and passes here, with both outputs.
- **Green suite:** the full suite and linters. If the repo forbids running the suite locally, run the affected tests and say CI will cover the rest.
- **Seen running:** run the app and exercise the change. For a gem or library, a script or console session.
- **Screenshots, when a person would see the change:** views, CSS, copy, emails, and new UI states, including transient ones like loading. A before and after pair at the same viewport, cropped to the change, about 4 images at most. Save them to `$(git rev-parse --git-dir)/nunebot-proof/` and never commit them. Skip them where another proof is stronger: text diffs for machine-readable output, curl output for status codes and auth, a byte-identical render diff for refactors, a terminal transcript for CLI and backend work.
- **Proven unused:** for removals, the searches and signals showing nothing references the code, plus the line count removed.
- **Measured:** before and after numbers for anything claiming to improve speed, cost, errors, or query load.

A fix made while proving gets its own commit and a review as in step 5, using any rounds left. If none are left, the status is `GAVE_UP`.

If you can't produce the proof, fix the change until you can. If that's not possible, the status is `BLOCKED`, with what you tried and everything you did prove.

## 8. Finish the ledger and report

Write the ledger in this shape, leaving out anything that doesn't apply:

```markdown
Status: DONE | GAVE_UP | BLOCKED
Branch: <branch>
Base: <branch>
Head: <sha>

## Simplify
What it trimmed, or that it changed nothing.

## QA
What it tested and found.

## Review
Each round: what was reviewed, findings fixed, findings rejected and why.

## Performance & compatibility

## Proof
The actual outputs and tables.

## Screenshots
Absolute path and alt text for each image.

## Risk and rollback

## Open findings
Only for GAVE_UP.

## Choices made unattended

## Steps for John
Anything only I can do before or after merge, such as a production check, a deploy step, or a setting.
```

Report the status, the ledger path, and one line per step. Don't push or open a PR. That's `nunebot-pr`.
