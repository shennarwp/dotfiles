---
id: TASK-9
title: Handle PROMPT_COMMAND as an array on bash >= 5.1
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - prompt
dependencies: []
references:
  - FIXME.md
priority: low
ordinal: 9000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The append guard in `merged/.bashrc` assumes the scalar form. With an array, `"${PROMPT_COMMAND}"` reads element 0 only and the assignment writes a string into index 0, leaving later elements orphaned (verified: `[0]="__makePS1;a" [1]="b"`). Low impact today since nothing in the repo sets the array, but the intent is not expressed.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Setting PROMPT_COMMAND to an array still appends __makePS1 without dropping elements
- [ ] #2 The scalar form still works
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
