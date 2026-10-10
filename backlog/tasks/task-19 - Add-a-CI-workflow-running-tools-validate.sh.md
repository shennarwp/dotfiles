---
id: TASK-19
title: Add a CI workflow running tools/validate.sh
status: Done
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-10 00:00'
labels:
  - ci
dependencies: []
references:
  - FIXME.md
priority: high
ordinal: 19000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Run `tools/validate.sh` on push and PR (syntax, vimrc, drift, newlines, JSON, gitleaks). Install `shellcheck` in CI so that pass stops being a local SKIP. This is the single largest gap: today every check runs only from a local pre-commit hook, so a fresh clone or a CI-only change is unverified.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A workflow file under .github/workflows runs tools/validate.sh on pull_request
- [x] #2 shellcheck is installed in CI, so that pass reports PASS rather than SKIP
- [x] #3 A deliberately broken .bashrc fails the workflow
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 tools/validate.sh passes
- [x] #2 PR opened against master, left unmerged
<!-- DOD:END -->
