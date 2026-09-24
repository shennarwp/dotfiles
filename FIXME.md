# Dotfiles improvements

Prioritized follow-up work for making the configuration safer, more portable,
and easier to deploy.

## High priority

- [ ] Add `tools/validate.sh` to run Bash syntax checks, ShellCheck when
  available, JSON/JSONC validation, and gitleaks.
- [ ] Add `tools/install-hooks.sh` and a tracked pre-commit hook so the gitleaks
  check is reproducible after a fresh clone. The current hook is local to
  `.git/hooks/` and is not tracked.
- [ ] Add timestamped backups and pre-deploy validation/permissions handling to
  `deploy.sh` (OS detection, dry-run, and host-variant selection are done).
- [ ] Remove or sanitize machine-specific information before publishing:
  usernames, email addresses, Windows paths, hostnames, and the Wake-on-LAN
  MAC address should be placeholders or local overrides.

## Portability and maintainability

- [ ] Make VS Code settings portable by separating shared settings from
  machine-specific SSH paths, usernames, and host aliases.
- [ ] Add a top-level workspace README describing the independent repositories
  and their common development commands.

## Shell quality-of-life improvements

- [ ] Make startup scripts robust when `HOSTNAME`, `hostname -f`, or optional
  utilities are unavailable.
- [ ] Preserve an existing `PROMPT_COMMAND` instead of replacing it.
- [ ] Quote command substitutions consistently and guard optional commands used
  by prompts and aliases.
- [ ] Improve history defaults with timestamps and multiline command support.

## CI and repository hygiene

- [ ] Add CI for shell syntax, ShellCheck, JSON/JSONC validation, gitleaks, and
  generated-file/duplicate-file drift checks.
- [ ] Add tests for the host-specific deployment matrix, especially QNAP,
  Alpine, and OpenWrt/ash compatibility.
- [ ] Check whether generated files such as coverage output and TypeScript
  build-info files in sibling repositories are ignored appropriately.
