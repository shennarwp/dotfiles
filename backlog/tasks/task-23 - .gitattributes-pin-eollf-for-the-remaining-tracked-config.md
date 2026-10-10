---
id: TASK-23
title: '.gitattributes: pin eol=lf for the remaining tracked config'
status: Done
assignee: []
created_date: '2026-10-01 19:38'
updated_date: '2026-10-10 00:00'
labels:
  - tools
dependencies: []
references:
  - FIXME.md
priority: low
ordinal: 23000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`*.jsonc`, `terminator/config` (TOML), `.gitignore`, `.gitleaks.toml` and the AGENTS.md-adjacent dotfiles fall back to `* text=auto`, which normalises in the index but does not guarantee LF in the worktree. Shell files already "choke on CRLF" per the file's own comment; add the remaining tracked config extensions for consistency.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Every tracked text config file has an explicit eol=lf entry
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 tools/validate.sh passes
- [x] #2 PR opened against master, left unmerged
<!-- DOD:END -->
