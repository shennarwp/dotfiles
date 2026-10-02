---
id: TASK-4
title: 'deploy.sh: no post-push verification'
status: Done
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - deploy
dependencies:
  - TASK-2
references:
  - FIXME.md
priority: medium
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Even once `fail` sets `EXIT_CODE`, a truncated write still looks like success on the local side — qnap has no `scp`, so files are piped over `ssh`. Compare `wc -c` (or a checksum) of the destination against the local file after each push.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A size mismatch on the remote side is reported and sets a non-zero exit
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
