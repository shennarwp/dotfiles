---
id: TASK-25
title: 'opencode/install.sh: pin versions and verify the fetched SKILL.md'
status: Done
assignee: []
created_date: 2026-10-01 19:38
updated_date: '2026-11-19T13:50:00Z'
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
- [x] #2 SKILL.md downloads are checksum-verified, or the behaviour is documented as unverified
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 tools/validate.sh passes
- [x] #2 PR opened against master, left unmerged
<!-- DOD:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: shennarwp
created: 2026-11-19T13:50:00Z

---

Won't fix by decision: opencode-ai is intentionally unpinned so installs always get the latest version. SKILL.md files are still fetched from upstream master over HTTPS without checksum verification; that behaviour is now documented in opencode/install.sh. AC #1 is deliberately not met.

---
<!-- COMMENTS:END -->
