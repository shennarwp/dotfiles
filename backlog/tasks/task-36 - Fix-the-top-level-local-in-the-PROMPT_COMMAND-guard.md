---
id: TASK-36
title: Fix the top-level local in the PROMPT_COMMAND guard
status: Done
assignee: []
created_date: '2026-11-19 00:00'
labels:
  - prompt
dependencies: []
ordinal: 36000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
TASK-9 added an array-aware PROMPT_COMMAND append guard to merged/.bashrc, but it uses `local _pc_found=0` at file scope. Bash rejects `local` outside a function, so the variable stays empty and the following `[ "$_pc_found" -eq 0 ]` reports `integer expected`. Seen on WSL Ubuntu 26.04 where bash-completion declares PROMPT_COMMAND as an array. The failed test also skips appending `__makePS1`, leaving the prompt stale. Use a plain assignment for this file-scope loop variable.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Sourcing .bashrc with an array PROMPT_COMMAND produces no startup errors and appends __makePS1
- [x] #2 The scalar PROMPT_COMMAND path is unchanged
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 tools/validate.sh passes
- [x] #2 PR opened against master, left unmerged
<!-- DOD:END -->
