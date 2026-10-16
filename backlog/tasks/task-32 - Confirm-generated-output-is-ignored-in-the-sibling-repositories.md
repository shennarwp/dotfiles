---
id: TASK-32
title: Confirm generated output is ignored in the sibling repositories
status: Done
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-16 08:50'
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

## Comments

<!-- COMMENTS:BEGIN -->
author: shennarwp
created: 2026-10-16 08:50
---
Won't fix — out of scope for this project. .gitignore rules for the sibling repositories live in those repositories, not here; this repo already ignores its own generated output.
---
<!-- COMMENTS:END -->
