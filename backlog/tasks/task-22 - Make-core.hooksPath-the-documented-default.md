---
id: TASK-22
title: Make core.hooksPath the documented default
status: In Progress
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-09 13:05'
labels:
  - tools
  - ci
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 22000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`tools/install-hooks.sh` supports `--hooks-path`, but it is not set in this clone, so a fresh clone depends on the copy step running by hand and can commit without any validation.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A documented command sets core.hooksPath, or install-hooks.sh defaults to hooks-path mode
- [ ] #2 AGENTS.md or README documents the one command a fresh clone needs
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
