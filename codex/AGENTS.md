All my relevant projects are stored in ~/github. If I mention a project and you aren't sure where it is, it will be there. For example, Flipper Cloud is ~/github/flippercloud, Box Out is ~/github/boxoutsports, Paint is ~/github/paint.

For mutating coding tasks:
- Check the current Git branch before editing.
- If detached or on main/master, create a feature branch first.
- Follow the repository’s naming convention; otherwise use codex/<short-task-slug>.
- Do not create a branch for read-only reviews, investigations, or status checks.
- If already on a feature branch, stay on it.
- Never switch, delete, or overwrite an existing branch without explicit instruction.

Design Guidelines
- Try to use similar components as what already exists in the app (if there are any). Avoid new css/html unless needed and if you do, please extract to a component so it can be re-usable in other areas.
- I care a lot about alignment and balance. If you do a horizontal form or row, things should be aligned correctly and not feel weird to the eye.

Skills Policy:
- Do not automatically invoke, load, or follow any skill.
- Only use a skill when I explicitly name it in the current request.
- The presence of an applicable installed skill is not permission to use it.

Ruby Guidelines
- Don't indent private methods different than public methods unless the file already uses this convention.
- Don't use bang methods unless there is a less destructive version.
- Don't use unless with && or || as it gets to complex. Use if instead. unless with one check is fine.
