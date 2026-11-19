---
id: TASK-31
title: Make the VS Code settings portable
status: Done
assignee: []
created_date: 2026-10-01 19:38
updated_date: '2026-11-19T13:55:00Z'
labels:
  - vscode
  - docs
dependencies:
  - TASK-5
references:
  - FIXME.md
priority: low
ordinal: 31000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
vscode/settings.json mixes shared editor settings with machine-specific WSL SSH paths, the Linux user name, and remote.SSH.* host aliases. Split them, e.g. a settings.local.json template or a documented patch step. Overlaps TASK-5, which is the public-repo sanitize pass.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Shared settings are separate from machine-specific paths
- [ ] #2 The apply step for the local layer is documented
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 tools/validate.sh passes
- [x] #2 PR opened against master, left unmerged
<!-- DOD:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: shennarwp
created: 2026-11-19T13:55:00Z

---

Won't fix: not necessary. The current single vscode/settings.json works fine; splitting out a local layer adds maintenance for no practical benefit here.

---
<!-- COMMENTS:END -->
