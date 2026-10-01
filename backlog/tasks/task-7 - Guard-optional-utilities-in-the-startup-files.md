---
id: TASK-7
title: Guard optional utilities in the startup files
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - prompt
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`FQDN=$(hostname -f)` (merged/.bashrc, merged-qnap/.bashrc) runs unguarded at every shell start and is embedded in the terminal title; `hostname -f` is unsupported on older busybox. Same treatment for `whoami`/`id -un`/`basename` where used in the prompt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `FQDN=$(hostname -f 2>/dev/null) || FQDN=$(hostname)` in both files
- [ ] #2 No error on a host whose hostname does not support -f
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
