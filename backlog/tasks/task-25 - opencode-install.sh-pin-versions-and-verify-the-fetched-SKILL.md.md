---
id: TASK-25
title: 'opencode/install.sh: pin versions and verify the fetched SKILL.md'
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - tools
  - privacy
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 25000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
It runs `npm install -g opencode-ai` unpinned (latest at install time) and curls `$SKILL_BASE/$s/SKILL.md` with no checksum, so the same commit produces different results on different days and a compromised endpoint is indistinguishable from a good run.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The opencode-ai version is pinned to an explicit value
- [ ] #2 SKILL.md downloads are checksum-verified, or the behaviour is documented as unverified
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
