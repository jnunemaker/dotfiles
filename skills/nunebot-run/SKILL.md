---
name: nunebot-run
description: Run one Nunebot pass over my repos, following the prompt in my brain repo, with an optional repo scope or PR cap. Use only when I name it.
---

# nunebot-run

Run one Nunebot pass. `~/github/brain/nunebot/PROMPT.md` is the spec. Pull brain first (`git -C ~/github/brain pull --ff-only`), read the whole prompt, and follow it. This skill only adds how to read my arguments. Where they conflict, my arguments win for this run only, and the prompt wins on everything else.

If the prompt is missing, stop and say so. Don't run from memory.

## Arguments

- **Repos:** names like `fireside` or `flare flipper` limit the run to those repos, in the prompt's priority order. Record the rest as "not reached (skipped by request)".
- **Cap:** a number like `cap 3`, or "up to 3 minus the open nunebot PRs", replaces the prompt's open-PR cap for this run.
- **Extra items:** anything else I write is an extra item for its repo. Treat it like a brain item: it comes first for that repo if it clears the obvious-yes bar.
- **`like last time`:** read only the newest entry at the top of `nunebot/runs.md` and reuse its scope and cap.

## Before starting

Say in one line which repos you'll run, the cap, and any extra items. Then start without waiting.

If your tool runs fewer subagents at once than the prompt's lanes, use fewer lanes, keeping the prompt's priority order.

## Finish

If a rule in the prompt turned out wrong or missing during the run, don't change `PROMPT.md` yourself. After the prompt's final report, list the change you'd make, then add one line: which repos are now at the PR cap.
