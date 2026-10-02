---
id: TASK-26
title: Refresh the stale .gitleaks.toml header comment
status: Done
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - tools
  - docs
dependencies: []
references:
  - FIXME.md
priority: low
ordinal: 26000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
It still references `gitleaks detect --pipe`, the subcommand removed in gitleaks 8.19.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The comment names the v8.19+ `gitleaks git` CLI that validate.sh actually calls
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
