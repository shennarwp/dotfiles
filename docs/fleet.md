# Fleet — hosts, versions, status

Volatile. If this disagrees with reality, fix this file, not `AGENTS.md`.

## Hosts

| Host | SSH alias | Home | Deploy source | Banner | Notes |
|------|-----------|------|---------------|--------|-------|
| x270 | (local) | `~` | `merged/` | fastfetch 2.40.4-debug (local) | WSL Debian 13 |
| m9 | `m9` | `~` | `merged/` | fastfetch 2.68.1 at `~/bin/fastfetch` | Debian 12 x86_64 |
| alp | `alp` | `~` | `merged/` | fastfetch 2.68.1 at `~/bin/fastfetch` | Debian 12 x86_64 |
| rui | `rui` | `~` | `merged/` | fastfetch 2.68.1 at `~/bin/fastfetch` (aarch64) | Ubuntu 24.04, symlinked dotfiles (dotfiles-manager) |
| fata | `fata` | `~` | `merged/` | fastfetch 2.68.1 (polyfilled `.deb`) | Debian 11, curl only |
| zot | `zot` | `~` | `merged/` | fastfetch 2.40.4-debug at `/usr/bin/fastfetch` | Debian 13 x86_64 |
| qnap | `qnap` | `/root` | `merged-qnap/` + `merged/.bash_aliases` | neofetch 7.1.0 at `/root/bin/neofetch` | bash 3.2.57, no scp |
| alpine | `gpd` | `~` | `merged/` + `merged-alpine/.bash_aliases_local` | fastfetch (`apk add fastfetch`) | Alpine 3.24, no `tput` |
| openwrt | `omg` | `/root` | `merged-openwrt/` | pfetch at `~/.pfetch` | ash/busybox, wget only |

Non-obvious SSH aliases: `gpd` (alpine), `omg` (openwrt), `qnap`.

## Open tasks that matter most

Full board: `backlog/tasks/`. Highlights:

- **TASK-1** — stop `deploy.sh` clobbering `.bash_aliases_local` on qnap/alpine. Blocks safe key handling there.
- **TASK-2** — per-file deploy failures exit non-zero.
- **TASK-5, TASK-6** — sanitize machine-specific data from tracked files.
- **TASK-19** — add CI.
- **TASK-29 → TASK-30** — push new `.bashrc` to fleet; `NINEROUTER_URL` migration depends on it.

## GPG

Key `C06C4DD034067569` (Shenna, shennawew@outlook.com) migrated Cygwin → WSL gpg 2.4.7 (Sep 2026). Trust ultimate. Cygwin keyring emptied, backup at `~/cygwin-gnupg-backup-20260913-232224/`. Only this key remains on GitHub; the other two were removed.

In this clone `user.signingkey` is set but `commit.gpgsign` is `false`. Re-enable with `git config --local commit.gpgsign true` if signed commits are wanted.

## Recent deploys

- **x270, 2026-09-30** (`./deploy.sh --local-only`). Backups: `~/.dotfiles-backup-20260930-225618/`, `~/.dotfiles-backup-20260930-230147/`. Included: guarded Linuxbrew `shellenv`, `PROMPT_COMMAND` append (not replace), `seq`-free `allcolors`, idempotent PATH (`__path_prepend` in `merged/.bashrc`; guarded loop in `merged/.profile` and `merged-openwrt/.profile`; `src` no longer grows `$PATH`), `GOROOT`/`GOPATH` exported only where Go is installed.
- Remote hosts still need `./deploy.sh` once `~/.ssh/config` is restored.

## Known deltas / drift

- ANSI-only `.bashrc` (no tput) is live on alpine and local `~` only. m9/alp/rui/fata/zot still run the older tput-gated `.bashrc`. Push when convenient.
- `NINEROUTER_URL` moved out of `merged/.bashrc` into the host-local layer (2026-10-01). Any Debian host receiving the new `.bashrc` **without** `export NINEROUTER_URL="http://9router.m9.home.arpa"` in `~/.bash_aliases_local` loses the variable. Tracked as TASK-30, blocked on TASK-29.
- `~/.ssh/config` (local) has CRLF line endings; host aliases had trailing `\r` that broke `deploy.sh` until it started stripping CR. Keep that gentle in new tooling.
- If this clone has no `~/.ssh/config`, `deploy.sh` only deploys locally.

## Toolchain

- `gitleaks` 8.30.1 at `~/bin/gitleaks` (installed by `tools/install-tools.sh`). Uses v8.19+ CLI: `gitleaks git [--staged]`. The old `gitleaks detect --pipe` form no longer exists.
- `shellcheck` not installed on this machine → `tools/validate.sh` reports that pass as SKIP. `tools/install-tools.sh` installs it via apt.

## Backup pattern

`deploy.sh` backs up before every overwrite into `~/.dotfiles-backup-YYYYMMDD-HHMMSS/` (local and remote), keeps newest `BACKUP_KEEP` (default 10), prunes older. Manual backups are only needed for hand edits to live host files.

## Parked

Hooks/tooling are in place (`tools/` + `.githooks/`); nothing parked there.
