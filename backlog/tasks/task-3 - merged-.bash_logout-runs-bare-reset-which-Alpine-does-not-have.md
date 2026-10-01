---
id: TASK-3
title: 'merged/.bash_logout runs bare reset, which Alpine does not have'
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - deploy
dependencies: []
references:
  - FIXME.md
priority: high
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`reset` ships with ncurses termutils; Alpine is documented in AGENTS.md as having no ncurses, and `.bash_logout` is in the shared `MERGED_FILES` manifest, so every Alpine logout prints `reset: not found`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `.bash_logout` guards the call: `command -v reset >/dev/null && reset || clear`
- [ ] #2 No output on a host that has reset
- [ ] #3 tools/validate.sh passes
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
