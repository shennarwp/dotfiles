# Dotfiles improvements

Open follow-up work now lives in [Backlog.md](https://github.com/MrLesk/Backlog.md),
one Markdown task file per item under `backlog/tasks/`. This file is kept only as a
pointer so existing links do not go stale.

```bash
backlog board            # terminal kanban
backlog task list        # open tasks, grouped by priority
backlog search "deploy"  # fuzzy search across tasks
```

The 32 tasks below were migrated from this file on 2026-10-01 and carry the same
text plus acceptance criteria. Anything already covered by `tools/validate.sh`
(syntax, vimrc, qnap drift, trailing newlines, JSON, gitleaks) was dropped at
migration time and is not tracked.
