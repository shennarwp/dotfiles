---
id: TASK-1
title: deploy.sh overwrites the host-local override layer on qnap and alpine
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - deploy
  - privacy
dependencies: []
priority: high
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
deploy.sh:209 and deploy.sh:212 push `merged-alpine/.bash_aliases_local` and `merged-qnap/.bash_aliases_local` straight over the host's copy, so any secret a host keeps there — `NINEROUTER_KEY` lives there by design — is destroyed on the next deploy. The tracked copy silently wins; only `~/.dotfiles-backup-*` saves it. `merged/.bashrc`, `deploy_mode` in deploy.sh and `opencode/README.md` all claim the layer is "never overwritten", which is true for the debian/ubuntu/openwrt manifests and false for these two.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A key in a host's ~/.bash_aliases_local survives a deploy on every manifest
- [ ] #2 The deploy.sh header, deploy_mode comment and opencode/README.md no longer claim "never overwritten" where that is false
- [ ] #3 deploy.sh --dry-run output shows the append/merge behaviour for the qnap and alpine manifests
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
