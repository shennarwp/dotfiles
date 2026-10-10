---
id: TASK-27
title: Document the .bash_profile / .profile / .bashrc sourcing order
status: Done
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-10 00:00'
labels:
  - docs
dependencies: []
references:
  - FIXME.md
priority: low
ordinal: 27000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`.bash_profile` sources `.bashrc` then `.profile`, and on QNAP the `.bash_profile` variant is not deployed — worth a line in AGENTS.md so the next person does not "fix" `.bash_profile` for a host that never reads it.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 AGENTS.md states the sourcing chain and which hosts deploy which of the three files
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 tools/validate.sh passes
- [x] #2 PR opened against master, left unmerged
<!-- DOD:END -->
