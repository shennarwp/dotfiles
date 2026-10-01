---
id: TASK-11
title: Batch the SSH round-trips in deploy.sh
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - deploy
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 11000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Per Debian host it makes 21: `push` calls `backup_remote` (1 ssh), then scp, then a separate chmod ssh, for each of 7 files, plus the `probe_os`. Move the backup to one call per host and fold the `chmod` into the scp/pipe step. The backup-pruning logic is also duplicated between `prune_backups` and the `backup_remote` heredoc — a shared helper would halve it.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Backups for a host happen in one remote call, not one per file
- [ ] #2 The pruning logic exists once, not twice
- [ ] #3 A dry run makes no ssh connections
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
