All my relevant projects are stored in ~/github. If I mention a project and you aren't sure where it is, it will be there. For example, Flipper Cloud is ~/github/flippercloud, Box Out is ~/github/boxoutsports, Paint is ~/github/paint.

## For mutating coding tasks:
- Before editing, determine whether the current checkout is the project’s root checkout or a linked worktree, and check the current Git branch.
- In the root checkout, stay on the current branch unless explicitly asked to change it. Working and committing directly on `main` or `master` is allowed.
- In any linked worktree, never check out or work directly on `main` or `master`.
- When starting work in a linked worktree, immediately create and switch to a dedicated feature branch before editing. If already on an appropriate feature branch, stay on it.
- Follow the repository’s branch-naming convention. If none exists, use a short task slug with no agent or tool prefix.
- If the intended branch name already exists, create a unique variation rather than switching, deleting, or overwriting the existing branch.
- Do not create or change branches for read-only reviews, investigations, or status checks.
- Never switch, delete, or overwrite an existing branch without explicit instruction.

## Design Guidelines
- Try to use similar components as what already exists in the app (if there are any). Avoid new css/html unless needed and if you do, please extract to a component so it can be re-usable in other areas.
- I care a lot about alignment and balance. If you do a horizontal form or row, things should be aligned correctly and not feel weird to the eye.

## Skills Policy:
- Do not automatically invoke, load, or follow any skill.
- Only use a skill when I explicitly name it in the current request.
- The presence of an applicable installed skill is not permission to use it.

## Ruby Guidelines
- Don't indent private methods different than public methods unless the file already uses this convention.
- Don't use bang methods unless there is a less destructive version.
- Don't use unless with && or || as it gets to complex. Use if instead. unless with one check is fine.

## Secret-safe command output

Treat all command output as content sent to the model and retained in task logs.

- Never run commands that enumerate credentials, environment variables, or secret values into tool output. This includes `env`, `printenv`, `set`, `heroku config`, `heroku releases:info`, secret-manager reads, credential-file reads, and commands with options such as `--show-secrets`.
- For Heroku release monitoring, use `heroku releases --app <app>` for status and history. Use `heroku releases:output <release> --app <app>` only when necessary, because application output can also accidentally contain secrets.
- If a command’s output is unfamiliar, inspect `--help`, official documentation, or its source before running it against production.
- Prefer metadata-only commands and explicit field allowlists. Never rely solely on redacting known variable names or secret patterns.
- When potentially sensitive output is unavoidable, capture it locally without displaying it, scan it, and emit only explicitly allowlisted fields. If anything suspicious is detected, withhold the entire output and report only that it was blocked.
