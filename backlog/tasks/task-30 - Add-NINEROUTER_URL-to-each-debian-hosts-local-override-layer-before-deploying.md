---
id: TASK-30
title: Add NINEROUTER_URL to each debian host's local override layer before deploying
status: Done
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - deploy
dependencies:
  - TASK-29
references:
  - FIXME.md
priority: high
ordinal: 30000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
One line per host, before the new .bashrc reaches it: export NINEROUTER_URL="http://9router.m9.home.arpa". The shared .bashrc no longer hardcodes it, so a host that skips this loses NINEROUTER_URL and opencode fails on an empty baseURL. qnap and alpine already get it from their tracked local files; the debian hosts need it by hand.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 NINEROUTER_URL is set on m9, alp, rui, fata and zot
- [ ] #2 `opencode` starts and lists models on each of those hosts
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
