---
id: TASK-21
title: Add tests for the deployment matrix
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - ci
  - deploy
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 21000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
QNAP, Alpine, OpenWrt/ash: run `deploy.sh --dry-run` against a synthetic `~/.ssh/config` and assert each host resolves to the right manifest, without touching a real host.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A synthetic ssh config maps each fixture host to the expected manifest
- [ ] #2 The test never opens an ssh connection
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
