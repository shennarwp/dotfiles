---
id: TASK-32
title: Confirm generated output is ignored in the sibling repositories
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - tools
dependencies: []
references:
  - FIXME.md
priority: low
ordinal: 32000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
This repo's .gitignore covers coverage/, *.tsbuildinfo and friends, but only this tree. The sibling repositories need the same rules or their own builds will start tracking artifacts.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each sibling repo ignores coverage/, *.lcov, *.tsbuildinfo, .nyc_output/ and build-info/
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
