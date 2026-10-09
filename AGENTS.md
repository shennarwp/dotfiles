# AGENTS.md

Read before editing. `merged/` is the source of truth and is deployed live.

## Layout

- `merged/` — canonical bash config
- `merged-qnap/` — `.bashrc` (QNAP-specific), `.bash_functions`/`.bash_logout` (synced copies of `merged/`), `.bash_aliases_local` (busybox overrides: `ls`/`rm`/`mkdir`/`mv`, drops apt `uu`)
- `merged-alpine/` — `.bash_aliases_local` only (apk `uu`/`uug`/`aai`/`aas`)
- `merged-openwrt/` — standalone ash/busybox set: `.bash_aliases`, `.profile`. Never source `merged/.bash_functions` here (uses `function` keyword)
- `tools/` — `validate.sh`, `install-hooks.sh`, `install-tools.sh`
- `deploy.sh` — fleet deploy; backs up to `~/.dotfiles-backup-<ts>/` (`BACKUP_KEEP=10`). Flags: `--local-only`, `--no-backup`, `--dry-run`
- `opencode/`, `pidev/` — 9router clients; read `NINEROUTER_URL`/`NINEROUTER_KEY` from `~/.bash_aliases_local`, never hardcode
- `backlog/` — task board (Backlog.md), one file per task under `backlog/tasks/`
- `.githooks/pre-commit` — one command after clone: `tools/install-hooks.sh` sets `core.hooksPath=.githooks` (no copying)

See `docs/fleet.md` for host inventory, versions, and current status.

## Rules

- Never edit per-host copies if the change belongs in `merged/`.
- Per-host overrides go in `merged-qnap/.bash_aliases_local` or `merged-alpine/.bash_aliases_local`.
- After editing `merged/.bash_functions` or `.bash_logout`, sync to `merged-qnap/` (validate fails on drift).
- Every tracked text file ends with a newline (`tools/validate.sh --fix-newlines`). `*.rayconfig` is binary.
- Work on a branch and land via PR. Never push to `master`.

## Shell sourcing order

Interactive bash chain:

```
.bash_profile  →  .profile  →  .bashrc  →  .bash_aliases / .bash_functions
```

- `.bash_profile` is deployed only on standard bash hosts. On qnap/openwrt/alpine it is absent; `.profile` is the login entry point and `.bashrc` is the interactive config.
- `~/.bash_aliases_local` (0600) is sourced last by `.bashrc` and overrides host-local settings (e.g. `NINEROUTER_URL`). Never track this file in `merged/`.
- openwrt uses `.profile` → `.bash_aliases` directly; no `.bashrc` chain.

## Host constraints

- **qnap**: bash 3.2.57. No `jobs`, `tput`, `hostid`, `git`, `seq`, `scp`. ANSI-only prompt.
- **openwrt**: ash, not bash. No `[[ ]]`, arrays, `function`, curl. Only busybox `wget`. `spd` is a wget alias here (target `http://proof.ovh.net/files/100Mb.dat`).
- **alpine**: no `tput` (no ncurses); `__getMachineId` falls back to hostname hash.
- **fata**: curl only (no wget).
- **fastfetch**: no builds for qnap (ARMv5) or openwrt (MIPS) — use neofetch/pfetch there.

`spd` is a function in `merged/.bash_functions` on bash hosts (curl+awk MB summary); on openwrt it's a wget alias in `merged-openwrt/.bash_aliases`. Do not "unify" these.

## Prompt (non-negotiable)

- Host always shown, colored by `__getMachineId`.
- Input `$` red with newline after: `\[\e[31m\]\$\[\e[0m\]\n` (root: `#`).
- Zero `tput` dependency (ANSI-only). Must work on qnap/alpine.
- No jobs/screen blocks on QNAP/ANSI prompt.

## Secrets

- `NINEROUTER_URL`/`NINEROUTER_KEY` live in `~/.bash_aliases_local` (0600), sourced last by `.bashrc`. Never tracked.
- **Do not hand-edit `.bash_aliases_local` on qnap/alpine**: `deploy.sh` overwrites it with the tracked `merged-*` copy. Tracked files carry the gateway URL only. Key handling on those hosts is unresolved — see `docs/fleet.md` and TASK-1.

## Git workflow

```bash
tools/validate.sh                # syntax, vimrc, qnap drift, newlines, JSON, gitleaks
git checkout -b <type>/<slug>
git add -A && git commit         # hook runs validate --hook
git push -u origin <branch>
gh pr create --base master --head <branch>
```

- Commit style: `fix(scope):`, `feat(scope):`, `docs:`, `chore:`. Subject, blank line, body.
- Leave PRs unmerged unless asked. `BLOCKED` from GitGuardian/Copilot rules is expected — ask before `gh pr merge --admin`.
- After merge: `git checkout master && git pull`, delete local branch, `gh pr merge --delete-branch` handles remote.

## Deploy

- Standard hosts: copy `merged/{.bashrc,.bash_aliases,.bash_functions,.bash_profile,.profile,.bash_logout,.vimrc}` to `~/`.
- qnap: pipe over ssh (no scp). Deploy `merged-qnap/.bashrc`, `.bash_functions`, `.bash_logout`, `merged/.bash_aliases`, `merged-qnap/.bash_aliases_local`.
- openwrt: `merged-openwrt/.bash_aliases` + `.profile` only.
- alpine: `merged/` + `merged-alpine/.bash_aliases_local`.
- `deploy.sh` writes `.bash_aliases_local` as `0600`, others `0644`.
- If `~/.ssh/config` is missing, `deploy.sh` only runs locally.

Always run `tools/validate.sh` before deploying.

## Task tracking

Backlog.md, local-only, no telemetry. `backlog/config.yml` has `remote_operations: false`, `auto_commit: false`.

```bash
backlog board            # kanban
backlog task list        # open, by priority
backlog task view TASK-N
backlog search "deploy"
```

- Install: `npm i -g backlog.md`. **`npx backlog` resolves to an unrelated third-party package — always use the `.md` name.**
- `backlog init` only needed on a fresh clone.
- **One commit per task.** A PR may contain multiple tasks if the user asked for them together; otherwise one task per PR.
- Before starting a task: `backlog task edit <id> --status in_progress`.
- On completion: `backlog task edit <id> --status Done` (do not delete).
- Quirk: use `--acceptance-criteria`/`--ref`, not `-ac`/`-ref`.
- `FIXME.md` is a pointer only; open work lives in `backlog/tasks/`.

## Notes

- `*` in globs doesn't match leading dots — spell files out or use `tools/validate.sh`.
- `gitleaks` at `~/bin/gitleaks`, uses v8.19+ CLI (`gitleaks git [--staged]`).
- Missing `shellcheck` → validate reports SKIP. Install via `tools/install-tools.sh`.
- `~/.ssh/config` may have CRLF; `deploy.sh` strips `\r`.
