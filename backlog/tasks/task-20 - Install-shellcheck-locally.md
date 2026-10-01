---
id: TASK-20
title: Install shellcheck locally
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - tools
  - ci
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 20000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Until then `tools/validate.sh` reports that pass as SKIP, so a large fraction of the tracked shell files are unlinted on the machine that most often edits them.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `tools/install-tools.sh` has installed shellcheck
- [ ] #2 The shellcheck pass in validate.sh reports PASS with findings addressed
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
