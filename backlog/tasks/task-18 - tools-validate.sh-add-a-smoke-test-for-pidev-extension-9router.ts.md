---
id: TASK-18
title: 'tools/validate.sh: add a smoke test for pidev/extension/9router.ts'
status: Done
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-30 20:37'
labels:
  - validate
  - ci
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 18000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`pidev/extension/9router.ts` is executable TypeScript loaded by pi through `jiti`, and nothing in the repo parses it. A typo in the extension reaches a session instead of CI. A `jiti` import smoke test — load the factory, assert it calls `registerProvider` — would catch the common cases without a TypeScript dependency.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A deliberate syntax error in 9router.ts fails validate.sh
- [ ] #2 The pass reports SKIP when jiti is not installed
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Closed as obsolete: pidev/extension/9router.ts has been removed. The proposed jiti import smoke test and its acceptance criteria no longer apply. No change to tools/validate.sh is needed; the existing JSON validation covers pidev/models.json. Original criteria are retained unchecked because the test was not implemented.
<!-- SECTION:FINAL_SUMMARY:END -->
