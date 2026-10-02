---
id: TASK-29
title: Push the ANSI-only (no tput) .bashrc to the remote fleet
status: Done
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - deploy
dependencies: []
references:
  - FIXME.md
priority: high
ordinal: 29000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
m9, alp, rui, fata, zot still run the older tput-gated version. The guarded Linuxbrew shellenv, PROMPT_COMMAND append and seq-free allcolors are live on x270 only. This clone has no ~/.ssh/config, so deploy.sh can only deploy locally — recreate the config, then run `./deploy.sh --dry-run`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 ~/.ssh/config exists in this clone with the fleet aliases
- [ ] #2 `./deploy.sh --dry-run` shows a manifest for every host
- [ ] #3 All five hosts confirm the new .bashrc is live
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
