---
id: TASK-10
title: Stop using hardcoded line ranges for --help in the tooling
status: Done
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - tools
  - docs
dependencies: []
references:
  - FIXME.md
priority: high
ordinal: 10000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`deploy.sh` prints `sed -n '2,33p' "$0"` but its header ends at line 35, so the last two help lines are truncated. `tools/install-hooks.sh` uses `sed -n '3,17p'` against a header ending at 16, so `--help` leaks the `set -u` line into the output. Replace with a sentinel so the help text cannot drift out of sync with the header.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `./deploy.sh --help` prints the full header, including the Backups section
- [ ] #2 `tools/install-hooks.sh --help` no longer prints `set -u`
- [ ] #3 Adding a comment line to any header does not truncate or leak the help output
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
