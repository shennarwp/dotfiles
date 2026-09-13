# AGENTS.md

Guidance for another agent continuing dotfiles work. Read this before editing; the
`merged/` set is the source of truth and is deployed live on multiple machines.

## Layout (what survived the consolidation)

- `merged/` — single source of truth, deployed to standard bash hosts
- `merged-qnap/` — .bashrc is QNAP-specific; `.bash_aliases`/`.bash_functions`
  are sync'd copies of the `merged/` equivalents plus no additions (keep in sync)
- `merged-gpd/` — `.bash_aliases` = sync'd copy of `merged/` **plus a trailing
  Alpine/apk override section** (uu, uug, aai, aas). Keep the sync'd part in sync.
- `merged-omega/` — `.profile` is the omega config; it sources the *deployed*
  `~/.bash_aliases` (the shared file) at runtime, so there is no copy here.

Rules of thumb:
- Never edit per-host copies directly if the change belongs in `merged/`.
- After editing `merged/.bash_aliases` or `merged/.bash_functions`, sync:
  `cp merged/.bash_aliases merged-qnap/.bash_aliases` and
  `cp merged/.bash_aliases merged-gpd/.bash_aliases` then re-append the gpd
  apk override block (uu/uug/aai/aas).
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
| qnap | `qnap` (home /root) | `merged-qnap/` | neofetch 7.1.0 at `/root/bin/neofetch` | bash 3.2.57, no scp |
| gpd | `gpd` | `merged/` + `merged-gpd/.bash_aliases` | fastfetch (`apk add fastfetch`) | Alpine 3.24, needs ncurses for tput (prompt is ANSI-only now) |
| omega | `omg` (home /root) | `merged-omega/.profile` + shared aliases | pfetch `~/.pfetch` | OpenWrt ash/busybox, only curl-less `wget` |

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
- Host-specific only overrides in the per-host suffix (Alpine apk block, omega
  overrides in its `.profile`).
- `spd` is a FUNCTION in `.bash_functions` (bash hosts, curl+awk MB summary);
  on omega it is a wget alias defined in its `.profile`.

## Deployment

- Standard bash hosts: copy `merged/{.bashrc,.bash_aliases,.bash_functions,.bash_profile,.profile,.bash_logout,.vimrc}`
  to `~/` on the host.
- qnap: no scp, home is /root — pipe file contents over ssh into `~`.
- omega: deploy `merged/.bash_aliases` and `merged-omega/.profile` only.
- gpd: `merged/` files plus `merged-gpd/.bash_aliases` (apk overrides).
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