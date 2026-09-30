# AGENTS.md

Guidance for another agent continuing dotfiles work. Read this before editing; the
`merged/` set is the source of truth and is deployed live on multiple machines.

## Layout (what survived the consolidation)

- `merged/` — single source of truth, deployed to standard bash hosts
- `merged-qnap/` — `.bashrc` is QNAP-specific; `.bash_functions`/`.bash_logout`
  are sync'd copies of the `merged/` equivalents. `.bash_aliases_local` is the
  QNAP-only override layer (busybox `ls`/`rm`/`mkdir`/`mv`, drops apt `uu`);
  it is NOT a copy of `merged/.bash_aliases`.
- `merged-alpine/` — `.bash_aliases_local` is the Alpine-only override layer (apk
  `uu`/`uug`/`aai`/`aas`); everything else comes from `merged/`.
- `merged-openwrt/` — the OpenWrt host's config: a deliberately
  **BusyBox/ash-compatible** `.bash_aliases` (no GNU/Debian-specific flags like
  `rm -Iv`, `ls --color`, apt) plus a `.profile` that sources it. This is NOT a
  sync'd copy of `merged/`; keep it standalone.
- `tools/` — `validate.sh` (syntax, vimrc, qnap drift, trailing newlines, JSON,
  gitleaks), `install-hooks.sh` (tracked hooks → `.git/hooks`), `install-tools.sh`
  (gitleaks/shellcheck).
- `.githooks/pre-commit` — tracked hook source; run `tools/install-hooks.sh` after
  a fresh clone (`.git/hooks/` is not tracked).

Rules of thumb:
- Never edit per-host copies directly if the change belongs in `merged/`.
- Per-host alias overrides live in `merged-qnap/.bash_aliases_local` and
  `merged-alpine/.bash_aliases_local`, sourced from `.bashrc` after the common
  `.bash_aliases`.
- After editing `merged/.bash_functions` (or `.bash_logout`), sync:
  `cp merged/.bash_functions merged-qnap/.bash_functions` and
  `cp merged/.bash_logout merged-qnap/.bash_logout`. `tools/validate.sh` fails
  when they drift.
- After editing `merged/.bashrc`, also sync local copy `~/.bashrc` when you
  deploy locally.
- Every tracked text file ends with a newline (`tools/validate.sh --fix-newlines`
  repairs it); `*.rayconfig` is binary per `.gitattributes` and is exempt.

## Hosts & deployment map (status Sept 2026)

Standard deploy = push `merged/` files to `~/` on the host.

| Host | SSH alias | Deploy source | Banner | Notes |
|------|-----------|--------------|--------|-------|
| x270 | (local) | `merged/` → `~/` | fastfetch 2.40.4-debug (local) | WSL Debian 13 |
| m9 | `m9` | `merged/` | fastfetch 2.68.1 at `~/bin/fastfetch` | Debian 12 x86_64 |
| alp | `alp` | `merged/` | fastfetch 2.68.1 at `~/bin/fastfetch` | Debian 12 x86_64 |
| rui | `rui` | `merged/` | fastfetch 2.68.1 at `~/bin/fastfetch` (aarch64) | symlinked dotfiles config, Ubuntu 24.04 |
| fata | `fata` | `merged/` | fastfetch 2.68.1 (polyfilled .deb) | Debian 11 |
| zot | `zot` | `merged/` | fastfetch 2.40.4-debug at `/usr/bin/fastfetch` | Debian 13 x86_64 |
| qnap | `qnap` (home /root) | `merged-qnap/` + `merged/.bash_aliases` | neofetch 7.1.0 at `/root/bin/neofetch` | bash 3.2.57, no scp |
| alpine | `gpd` | `merged/` + `merged-alpine/.bash_aliases_local` | fastfetch (`apk add fastfetch`) | Alpine 3.24, needs ncurses for tput (prompt is ANSI-only now) |
| openwrt | `omg` (home /root) | `merged-openwrt/` (aliases + profile) | pfetch `~/.pfetch` | OpenWrt ash/busybox, only curl-less `wget` |

## Known environment limits per host

- qnap: no `jobs` builtin, no `tput`, no `hostid`, no `git`, no `seq`. Prompt
  is ANSI-only, jobs/screen blocks removed from prompt.
- openwrt: ash, not bash. `.bash_functions` uses `function` keyword → NEVER
  source it there. Only busybox `wget` (no curl) → `spd` uses OVH
  `http://proof.ovh.net/files/100Mb.dat`.
- alpine: dispose of ncurses → no `tput`; prompt gate was converted to ANSI-only;
  `__getMachineId` falls back to hashing hostname when no `machine-id`.
- fastfetch has no builds for QNAP (ARMv5) or openwrt (MIPS) → use neofetch/pfetch.
- fata has no wget, only curl.

## Prompt design (non-negotiables)

- Host is ALWAYS displayed, colored by machine id (`__getMachineId`).
- Input `$` is red with a newline after it (`\\$\\n`).
- QNAP/ANSI prompt: no jobs/screen-status blocks.
- The prompt must work with zero `tput` dependency (ANSI-only).

## Aliases/functions conventions

- Everything lives in `merged/.bash_aliases` / `merged/.bash_functions`.
- Host-specific only overrides in the per-host `.bash_aliases_local` suffix
  (Alpine apk block, QNAP busybox block); the openwrt aliases are a standalone
  ash-compatible set in `merged-openwrt/`.
- `spd` is a FUNCTION in `.bash_functions` (bash hosts, curl+awk MB summary);
  on openwrt it is a wget alias in `merged-openwrt/.bash_aliases`.

## Deployment

- Standard bash hosts: copy `merged/{.bashrc,.bash_aliases,.bash_functions,.bash_profile,.profile,.bash_logout,.vimrc}`
  to `~/` on the host.
- qnap: no scp, home is /root — pipe file contents over ssh into `~`. Deploy
  `merged-qnap/.bashrc` + `merged-qnap/.bash_functions` + `merged-qnap/.bash_logout`
  + `merged/.bash_aliases` + `merged-qnap/.bash_aliases_local`.
- openwrt: deploy `merged-openwrt/.bash_aliases` and `merged-openwrt/.profile`
  only (ssh alias `omg`).
- alpine: `merged/` files plus `merged-alpine/.bash_aliases_local` (apk
  overrides; ssh alias `gpd`).
- local x270: `cp merged/{...} ~/`.
- rui/fata: dotfiles are symlinks (dotfiles-manager), scp follows them.

## Always run before deploying

```bash
tools/validate.sh
```

That covers `bash -n` on every tracked shell file, the vimrc source check, qnap
copy drift, trailing newlines, JSON/JSONC, and gitleaks. `--hook` is the
pre-commit subset; `--fix-newlines` repairs missing final newlines.

Note for hand-rolled checks: `*` does not match a leading dot, so
`merged-qnap/*.bash*` matches nothing. Spell the files out
(`merged-qnap/.bashrc merged-qnap/.bash_functions ...`) or use
`tools/validate.sh`.

## Backups pattern

When editing a host's live dotfiles, make a backup dir like
`~/.dotfiles-backup-YYYYMMDD-HHMMSS/` (see host backups,
e.g. local `~/.dotfiles-backup-20260912-231104`). `deploy.sh` does not do this
for you yet — see FIXME.md.

## Parked work

- Hooks/tooling are in place (`tools/` + `.githooks/`); nothing parked there.
- Still open: sanitize machine-specific data from tracked files, make
  `deploy.sh` back up before overwriting, add CI, and run the deployment-matrix
  tests. See FIXME.md for the full list.

## Todo / known deltas

- `~/.ssh/config` (local) has CRLF line endings; host aliases there had a
  trailing `\r` that broke `deploy.sh` until it started stripping CR. Keep
  that gentle in any new tooling.
- **This clone has no `~/.ssh/config`**, so `deploy.sh` finds no remote hosts and
  only deploys locally. Recreate the config (fleet aliases) before relying on
  fleet deploys; `gpd`/`omg`/`qnap` are the non-obvious alias names.
- Updated ANSI-only `.bashrc` (no tput) deployed to alpine and local `~` only;
  other hosts still run the tput-gated older `.bashrc`. Push to m9/alp/rui/fata
  when convenient.
- **Live on x270 since 2026-09-30** (`./deploy.sh --local-only`, backups at
  `~/.dotfiles-backup-20260930-225618/` and `~/.dotfiles-backup-20260930-230147/`):
  guarded Linuxbrew `shellenv`, `PROMPT_COMMAND` append instead of replace,
  `seq`-free `allcolors`, the idempotent PATH handling (`__path_prepend` in
  `merged/.bashrc`, guarded loop in `merged/.profile` and
  `merged-openwrt/.profile`, `src` no longer grows `$PATH`), and `GOROOT`/`GOPATH`
  only exported where Go is installed. The remote hosts still need
  `./deploy.sh` once `~/.ssh/config` is back.
- **GPG key migrated Cygwin → WSL (Sep 2026).** Key `C06C4DD034067569` (Shenna,
  shennawew@outlook.com) imported into WSL gpg 2.4.7, trust ultimate, Cygwin
  keyring emptied (backup at `~/cygwin-gnupg-backup-20260913-232224/`). In this
  clone `user.signingkey` is set but `commit.gpgsign` is `false`; re-enable with
  `git config --local commit.gpgsign true` if signed commits are wanted. The
  other two GPG keys were removed from GitHub; only `C06C4DD034067569` remains.
- `gitleaks` is installed at `~/bin/gitleaks` (8.30.1) by `tools/install-tools.sh`
  and uses the v8.19+ CLI (`gitleaks git [--staged]`); the old
  `gitleaks detect --pipe` from older docs no longer exists.
- `shellcheck` is still absent on this machine, so `tools/validate.sh` reports
  that pass as SKIP; `tools/install-tools.sh` installs it via apt.
