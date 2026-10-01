---
id: TASK-24
title: vscode/wsl-ssh.bat is unchecked and unconstrained
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - validate
dependencies: []
references:
  - FIXME.md
priority: medium
ordinal: 24000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
It is the only Windows-executed script in the repo, gets no syntax pass from tools/validate.sh (it is not in `is_shell_file`), has no `eol=crlf` entry in .gitattributes — it ships LF today, which `cmd.exe` mostly tolerates but not reliably — and install-hooks.sh/validate.sh cannot catch a typo in it.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The file has an eol=crlf entry
- [ ] #2 validate.sh asserts the expected eol attribute for it
- [ ] #3 A CRLF file is reported rather than silently normalized
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
