---
id: TASK-15
title: 'tools/validate.sh: add a *.jsonc pass'
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - validate
  - ci
dependencies: []
references:
  - FIXME.md
priority: high
ordinal: 15000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`json_file()` matches only `*.json|*.sublime-settings`, so `opencode/opencode.jsonc` — the file with the most config in the repo — is never parsed, despite the help text advertising a "JSON / JSONC" check.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `opencode/opencode.jsonc` is listed in the json/jsonc pass output
- [ ] #2 A deliberately broken .jsonc makes validate.sh fail
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
