---
id: TASK-16
title: 'tools/validate.sh: add an ash/dash syntax pass for merged-openwrt/'
status: Done
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-10 00:00'
labels:
  - validate
  - ci
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 16000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`bash -n` passes on ash files, so a bash-only construct (`[[ ]]`, arrays, `local -a`, `$'...'`) in the deliberately ash-compatible openwrt set passes CI and then breaks on the MIPS box. That directory exists precisely to be ash-safe. Gate a `busybox ash -n` (or `dash -n`) pass on the command being present.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A bash-only construct in merged-openwrt/.bash_aliases or .profile fails validate.sh
- [x] #2 The pass reports SKIP, not failure, when neither ash nor dash is installed
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 tools/validate.sh passes
- [x] #2 PR opened against master, left unmerged
<!-- DOD:END -->
