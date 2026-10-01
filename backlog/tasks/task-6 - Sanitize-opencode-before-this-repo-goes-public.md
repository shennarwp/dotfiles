---
id: TASK-6
title: Sanitize opencode/ before this repo goes public
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - privacy
  - opencode
dependencies:
  - TASK-5
references:
  - FIXME.md
priority: high
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`opencode/README.md` documents the internal ZeroTier address `10.147.17.5` and the LAN name, and `opencode/opencode.jsonc` plus `opencode/install.sh` carry the same gateway endpoint. The existing sanitize item only names `merged/.bash_aliases` and `vscode/settings.json`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 No internal IP or internal hostname in tracked opencode/ files
- [ ] #2 The documented gateway reference uses a placeholder
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
