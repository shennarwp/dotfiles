---
id: TASK-17
title: 'tools/validate.sh: syntax-check terminator/config and the sublime keymaps'
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - validate
  - ci
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 17000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`terminator/config` is TOML and gets no check at all; `sublime-text/*.sublime-keymap` is JSON-shaped but misses the `*.json` glob.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 terminator/config is parsed by a TOML check or documented as intentionally unvalidated
- [ ] #2 *.sublime-keymap is validated as JSON
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
