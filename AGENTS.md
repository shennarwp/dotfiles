# AGENTS.md

Guidance for another agent continuing dotfiles work. Read this before editing; the
`merged/` set is the source of truth and is deployed live on multiple machines.

## Layout (what survived the consolidation)

- `merged/` — single source of truth, deployed to standard bash hosts
- `merged-qnap/` — `.bashrc` is QNAP-specific; `.bash_functions`/`.bash_logout`
  are sync'd copies of the `merged/` equivalents. `.bash_aliases_local` is the
  QNAP-only override layer (busybox `ls`/`rm`/`mkdir`/`mv`, drops apt `uu`);
  it is NOT a copy of `merged/.bash_aliases`.
- `merged-gpd/` — `.bash_aliases_local` is the Alpine-only override layer (apk
  `uu`/`uug`/`aai`/`aas`); everything else comes from `merged/`.
- `merged-omega/` — omega config: a deliberately **BusyBox/ash-compatible**
  `.bash_aliases` (no GNU/Debian-specific flags like `rm -Iv`, `ls --color`,
  apt) plus a `.profile` that sources it. This is NOT a sync'd copy of
  `merged/`; keep it standalone.

Rules of thumb:
- Never edit per-host copies directly if the change belongs in `merged/`.
- Per-host alias overrides live in `merged-qnap/.bash_aliases_local` and
  `merged-gpd/.bash_aliases_local`, sourced from `.bashrc` after the common
  `.bash_aliases`.
- After editing `merged/.bash_functions`, sync:
  `cp merged/.bash_functions merged-qnap/.bash_functions`.
- After editing `merged/.bashrc`, also sync local copy `~/.bashrc` when you
  deploy locally.

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
| gpd | `gpd` | `merged/` + `merged-gpd/.bash_aliases_local` | fastfetch (`apk add fastfetch`) | Alpine 3.24, needs ncurses for tput (prompt is ANSI-only now) |
| omega | `omg` (home /root) | `merged-omega/` (aliases + profile) | pfetch `~/.pfetch` | OpenWrt ash/busybox, only curl-less `wget` |

## Known environment limits per host

- qnap: no `jobs` builtin, no `tput`, no `hostid`, no `git`, no `seq`. Prompt
  is ANSI-only, jobs/screen blocks removed from prompt.
- omega: ash, not bash. `.bash_functions` uses `function` keyword → NEVER
  source it there. Only busybox `wget` (no curl) → `spd` uses OVH
  `http://proof.ovh.net/files/100Mb.dat`.
- gpd: dispose of ncurses → no `tput`; prompt gate was converted to ANSI-only;
  `__getMachineId` falls back to hashing hostname when no `machine-id`.
- fastfetch has no builds for QNAP (ARMv5) or omega (MIPS) → use neofetch/pfetch.
- fata has no wget, only curl.

## Prompt design (non-negotiables)

- Host is ALWAYS displayed, colored by machine id (`__getMachineId`).
- Input `$` is red with a newline after it (`\\$\\n`).
- QNAP/ANSI prompt: no jobs/screen-status blocks.
- The prompt must work with zero `tput` dependency (ANSI-only).

## Aliases/functions conventions

- Everything lives in `merged/.bash_aliases` / `merged/.bash_functions`.
- Host-specific only overrides in the per-host `.bash_aliases_local` suffix
  (Alpine apk block, QNAP busybox block); the omega aliases are a standalone
  ash-compatible set in `merged-omega/`.
- `spd` is a FUNCTION in `.bash_functions` (bash hosts, curl+awk MB summary);
  on omega it is a wget alias in `merged-omega/.bash_aliases`.

## Deployment

- Standard bash hosts: copy `merged/{.bashrc,.bash_aliases,.bash_functions,.bash_profile,.profile,.bash_logout,.vimrc}`
  to `~/` on the host.
- qnap: no scp, home is /root — pipe file contents over ssh into `~`. Deploy
  `merged-qnap/.bashrc` + `merged-qnap/.bash_functions` + `merged-qnap/.bash_logout`
  + `merged/.bash_aliases` + `merged-qnap/.bash_aliases_local`.
- omega: deploy `merged-omega/.bash_aliases` and `merged-omega/.profile` only.
- gpd: `merged/` files plus `merged-gpd/.bash_aliases_local` (apk overrides).
- local x270: `cp merged/{...} ~/`.
- rui/fata: dotfiles are symlinks (dotfiles-manager), scp follows them.

## Always run before deploying

```bash
bash -n merged/.bashrc merged/.bash_aliases merged/.bash_functions merged-qnap/*.bash*
```

## Backups pattern

When editing a host's live dotfiles, make a backup dir like
`~/.dotfiles-backup-YYYYMMDD-HHMMSS/` (see host backups,
e.g. local `~/.dotfiles-backup-20260912-231104`).

## Parked work

- Automate deployment with a multi-OS `deploy.sh` that reads `~/.ssh/config`
  hosts, probes OS (debian/ubuntu|alpine|qnap|openwrt) and deploys per-OS
  manifests. User parked this; revisit only on request.

## Todo / known deltas

- Updated ANSI-only `.bashrc` (no tput) deployed to gpd and local `~` only;
  other hosts still run the tput-gated older `.bashrc`. Push to m9/alp/rui/fata
  when convenient.
- **DONE (Sep 2026): GPG key migrated Cygwin → WSL.** Key
  `C06C4DD034067569` (Shenna, shennawew@outlook.com) imported into WSL gpg
  2.4.7, trust ultimate, Cygwin keyring emptied (backup at
  `~/cygwin-gnupg-backup-20260913-232224/`). Git signing enabled repo-local
  (`user.signingkey C06C4DD034067569`, `commit.gpgsign true`). The other two
  GPG keys were removed from GitHub; only `C06C4DD034067569` remains.