---
id: TASK-13
title: Expand merged/.vimrc
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - docs
dependencies: []
references:
  - FIXME.md
priority: low
ordinal: 13000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Four lines today: no `set hidden`, no clipboard, no `undofile`, no `termguicolors`, and an unconditional `syntax on` that is slow on large files. It deploys to every bash host, so this is a cheap win for the whole fleet.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `tools/validate.sh` vimrc source check still passes
- [ ] #2 The choice of each added option is commented with the reason
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
