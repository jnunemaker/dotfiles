---
name: simplify
description: Review the changed code for reuse, simplification, efficiency, and altitude cleanups, then apply the fixes. Quality only, not a bug hunt. Use only when I name it.
---

# simplify

Shave the current change down. This is Codex's version of the `/simplify` built into Claude Code.

Look only at the change: the diff against the base branch (`gh pr view --json baseRefName -q .baseRefName`, otherwise the branch `origin/HEAD` points at), plus any uncommitted work. Read enough of the surrounding code to judge it.

Look for:

- **Reuse:** new code that duplicates a helper, component, or pattern the repo already has.
- **Simplification:** dead branches, needless abstraction, unnecessary state, defensive checks for things that can't happen, comments that restate the code, and leftover debugging.
- **Efficiency:** repeated work, N+1 queries, and needless allocations or requests on a hot path.
- **Altitude:** code at the wrong level, such as a fix in every caller that belongs in the shared function, or a framework written for one use.

Apply the fixes that are clearly better. Keep behavior the same, follow the repo's conventions, and leave code outside the change alone. Don't hunt for bugs or add features.

Run the tests covering what you touched. Then report what you trimmed, or say it was already tight.
