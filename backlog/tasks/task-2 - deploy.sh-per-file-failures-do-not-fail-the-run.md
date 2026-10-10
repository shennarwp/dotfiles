---
id: TASK-2
title: 'deploy.sh: per-file failures do not fail the run'
status: Done
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-10 00:00'
labels:
  - deploy
dependencies: []
references:
  - FIXME.md
priority: high
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`deploy_remote` calls `push ... || fail "$host: $f"`, but `fail` only prints — it never sets `EXIT_CODE` — and `deploy_remote` then returns 0, so the `if ! deploy_remote` guard never trips. A host whose `.bashrc` failed to land still prints "== all hosts deployed ==" and exits 0.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A push that returns non-zero makes deploy.sh exit non-zero
- [x] #2 The failing filename and host are named in the output
- [x] #3 A successful run still exits 0
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 tools/validate.sh passes
- [x] #2 PR opened against master, left unmerged
<!-- DOD:END -->
