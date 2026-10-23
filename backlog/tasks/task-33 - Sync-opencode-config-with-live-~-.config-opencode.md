---
id: TASK-33
title: Sync opencode config with live ~/.config/opencode
status: Done
assignee: []
created_date: '2026-10-23 21:44'
labels: []
dependencies: []
ordinal: 33000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Mirror the live ~/.config/opencode setup in the repo. Drop the 9router autodiscover plugin and the oc-free provider; declare the 19 9router models by hand. Add cli.json. Move the kan MCP bearer token to {env:KAN_TOKEN}. Update README.
<!-- SECTION:DESCRIPTION:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
