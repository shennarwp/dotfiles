# Dotfiles improvements

Open follow-up work, most valuable first. Anything already covered by
`tools/validate.sh` (syntax, vimrc, qnap drift, trailing newlines, JSON, gitleaks)
is done and no longer tracked here.

## High priority

- [ ] **Deploy the pending `merged/` changes to the remote fleet.** The guarded
  Linuxbrew `shellenv`, `PROMPT_COMMAND` append, and `seq`-free `allcolors` are
  live on x270 (deployed 2026-09-30 via `./deploy.sh --local-only`) but not on
  any remote host. This clone has no `~/.ssh/config`, so `./deploy.sh` can only
  deploy locally — recreate the config, then `./deploy.sh --dry-run`.
- [ ] **`deploy.sh`: back up before overwriting.** `deploy_local` and `push`
  replace `~/.bashrc` etc. with no backup. Create
  `~/.dotfiles-backup-YYYYMMDD-HHMMSS/` (or per-file `.bak`) like the manual
  host backups, and set sane permissions (0644) on what it writes.
- [ ] **Remove machine-specific data from tracked files** before this repo goes
  anywhere public:
  - `merged/.bash_aliases`: Wake-on-LAN MAC (`wakex41`), the Cygwin/OneDrive
    path with a Windows user name (`ch tw`), and the Windows-only aliases
    (`subl`, `spt`, `sb`). Move them to a Windows-host `.bash_aliases_local` or
    parameterize via variables.
  - `vscode/settings.json`: WSL SSH path, host aliases (`remote.SSH.*`).
  - `deploy.sh`/README: SSH alias names are fine, IPs/ports are not present —
      keep it that way.

## Portability and maintainability

- [ ] **Make the VS Code settings portable**: split shared settings from
  machine-specific SSH paths, usernames, and host aliases (e.g. a
  `settings.local.json` template or documented patch step).
- [ ] **Guard optional utilities in the startup files.** `FQDN=$(hostname -f)`
  (`merged/.bashrc`, `merged-qnap/.bashrc`) runs unguarded at every shell start
  and is embedded in the terminal title; fall back to `hostname` when `-f` is
  unsupported (older busybox). Same treatment for `whoami`/`id -un`/`basename`
  where used in the prompt.
- [ ] **Improve history defaults**: `HISTTIMEFORMAT`, `shopt -s lithist`,
  `cmdhist` for multiline commands (remember: QNAP runs bash 3.2, so no
  `HISTTIMEFORMAT` features that require newer bash).
- [ ] Add a top-level workspace README describing the independent repositories
  and their common development commands.

## CI and repository hygiene

- [ ] **CI workflow** running `tools/validate.sh` on push/PR (syntax, vimrc,
  drift, newlines, JSON, gitleaks). Install `shellcheck` in CI so that pass
  stops being a local SKIP.
- [ ] **Install `shellcheck` locally** (`tools/install-tools.sh`); until then
  `tools/validate.sh` reports that pass as SKIP.
- [ ] **Tests for the deployment matrix** (QNAP, Alpine, OpenWrt/ash): run
  `deploy.sh --dry-run` against a synthetic `~/.ssh/config` and assert each host
  resolves to the right manifest, without touching a real host.
- [ ] Confirm generated output (coverage, `*.tsbuildinfo`) is ignored in the
  sibling repositories too — this repo's `.gitignore` covers only this tree.

## Deployment order

- [ ] Push the ANSI-only (no `tput`) `.bashrc` to `m9`, `alp`, `rui`, `fata`,
  `zot` — they still run the older tput-gated version.
