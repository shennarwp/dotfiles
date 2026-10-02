---
id: TASK-8
title: Trim the prompt fork count in __makePS1
status: Done
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - prompt
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Forks 8+ processes per prompt: `$(command -v git)`, `$(git name-rev)`, `$(git status --porcelain)`, two `$(echo | grep | sed)` passes, one `$(echo | sort | uniq | tr)`, `$(jobs -p | wc -w)`, and three `$(whoami)` for the screen paths. Cheap wins: use the already-exported `$USER` instead of `whoami` and build SCREEN_PATHS once at load time; consider `git status --porcelain -uno` or gating on `$GIT_OPTIONAL_LOCKS`. `git name-rev` is also deprecated — switch to `git rev-parse --abbrev-ref HEAD`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 No `$(whoami)` in __makePS1; the three call sites use $USER
- [x] #2 SCREEN_PATHS is computed once at load, not per prompt
- [x] #3 The branch name comes from `git rev-parse --abbrev-ref HEAD`
- [x] #4 Prompt output is unchanged apart from the branch source
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
