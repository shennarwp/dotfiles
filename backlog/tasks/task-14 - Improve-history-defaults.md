---
id: TASK-14
title: Improve history defaults
status: Done
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - prompt
dependencies: []
references:
  - FIXME.md
priority: low
ordinal: 14000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`HISTTIMEFORMAT`, `shopt -s lithist`, `cmdhist` for multiline commands. Remember QNAP runs bash 3.2, so avoid `HISTTIMEFORMAT` features that need newer bash, and the qnap .bashrc is a separate file.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 History options are set in merged/.bashrc and mirrored or deliberately omitted in merged-qnap/.bashrc
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
