---
id: TASK-28
title: Add a top-level workspace README describing the sibling repositories
status: Done
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-16 08:50'
labels:
  - docs
dependencies: []
references:
  - FIXME.md
priority: low
ordinal: 28000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The independent repositories and their common development commands are undocumented outside this repo.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A README lists each sibling repo and the commands shared across them
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
Won't fix — out of scope for this project. The sibling repositories are independent and document their own workflows; a workspace-level README does not belong in the dotfiles repo.
---
<!-- COMMENTS:END -->
