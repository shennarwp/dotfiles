---
id: TASK-12
title: Accept that the rm guard alias is only a speed bump
status: To Do
assignee: []
created_date: '2026-10-01 19:38'
labels:
  - docs
dependencies: []
references:
  - FIXME.md
priority: low
ordinal: 12000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`merged/.bash_aliases` sets `alias rm='rm -Iv --one-file-system --preserve-root'`, but `-f` overrides `-I` entirely, so `rm -rf` through the alias deletes with no prompt (verified). Aliases are also not expanded inside functions, so `pirm`'s own `rm -fv` is unaffected either way. Either drop `-f` from the alias to make the guard real, or document it as advisory rather than a safety net.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A comment above the alias states whether it is a hard guard or advisory
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 tools/validate.sh passes
- [ ] #2 PR opened against master, left unmerged
<!-- DOD:END -->
