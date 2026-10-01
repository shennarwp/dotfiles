---
id: TASK-5
title: Remove machine-specific data from tracked files before the repo goes public
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - privacy
dependencies: []
references:
  - FIXME.md
priority: high
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The repo is public. Known tracked data: `merged/.bash_aliases` has the Wake-on-LAN MAC (`wakex41`), the Cygwin/OneDrive path with a Windows user name (`ch tw`), and the Windows-only aliases (`subl`, `spt`, `sb`); `vscode/settings.json` has the WSL SSH path and `remote.SSH.*` host aliases; `AGENTS.md` has a real email address and the GPG key id; `terminator/config` has the user name. Move the Windows-only bits to a Windows-host `.bash_aliases_local` or parameterize via variables.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 No MAC address, Windows user name, personal email or home-directory path in any tracked file
- [ ] #2 gitleaks still passes over full history
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
