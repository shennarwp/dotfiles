---
id: TASK-3
title: 'merged/.bash_logout runs bare reset, which Alpine does not have'
status: Done
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-10 00:00'
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
- [x] #1 `.bash_logout` guards the call: `command -v reset >/dev/null && reset || clear`
- [x] #2 No output on a host that has reset
- [x] #3 tools/validate.sh passes
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 tools/validate.sh passes
- [x] #2 PR opened against master, left unmerged
<!-- DOD:END -->
