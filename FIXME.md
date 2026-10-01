# Dotfiles improvements

Open follow-up work, most valuable first. Anything already covered by
`tools/validate.sh` (syntax, vimrc, qnap drift, trailing newlines, JSON, gitleaks)
is done and no longer tracked here.

## High priority

- [ ] **`deploy.sh` overwrites `~/.bash_aliases_local` on qnap and alpine.**
  `deploy.sh:209` and `deploy.sh:212` push `merged-alpine/.bash_aliases_local`
  and `merged-qnap/.bash_aliases_local` straight over the host's copy, so any
  secret a host keeps there — `NINEROUTER_KEY` lives there by design — is
  destroyed on the next deploy (the tracked copy silently wins; only the
  `~/.dotfiles-backup-*` dir saves it). `merged/.bashrc`, `deploy_mode` in
  `deploy.sh` and `opencode/README.md` all claim the layer is "never
  overwritten", which is true for the debian/ubuntu/openwrt manifests and
  false for these two. Either append the tracked block to the host file instead
  of replacing it, move secrets to a separate `~/.bash_aliases_secret`, or stop
  deploying the local layer at all.

- [ ] **Deploy the pending `merged/` changes to the remote fleet.** The guarded
  Linuxbrew `shellenv`, `PROMPT_COMMAND` append, and `seq`-free `allcolors` are
  live on x270 (deployed 2026-09-30 via `./deploy.sh --local-only`) but not on
  any remote host. This clone has no `~/.ssh/config`, so `./deploy.sh` can only
  deploy locally — recreate the config, then `./deploy.sh --dry-run`.
- [ ] **`deploy.sh`: per-file failures do not fail the run.** `deploy_remote`
  calls `push ... || fail "$host: $f"`, but `fail` only prints — it never sets
  `EXIT_CODE` — and `deploy_remote` then returns 0, so the `if ! deploy_remote`
  guard never trips. A host whose `.bashrc` failed to land still prints
  "== all hosts deployed ==" and exits 0. Fix: have `fail` set `EXIT_CODE=1`, or
  accumulate a per-manifest failure flag.
- [ ] **`merged/.bash_logout` runs bare `reset`, which Alpine does not have.**
  `reset` ships with ncurses' termutils; Alpine is documented in AGENTS.md as
  having no ncurses, and `.bash_logout` is in the shared `MERGED_FILES`
  manifest, so every Alpine logout prints `reset: not found`. Guard it:
  `command -v reset >/dev/null && reset || clear` (busybox `clear` exists).
- [ ] **`deploy.sh`: no post-push verification.** Even once `fail` sets
  `EXIT_CODE`, a truncated write still looks like success on the local side —
  qnap has no `scp`, so files are piped over `ssh`. Compare `wc -c` (or a
  checksum) of the destination against the local file after each push.
- [ ] **Sanitize `opencode/` before this repo goes public.** `opencode/README.md`
  documents the internal ZeroTier address `10.147.17.5` and the LAN name from
  `94946dc`, and `opencode/opencode.jsonc` carries the same gateway endpoint.
  The existing sanitize item only names `merged/.bash_aliases` and
  `vscode/settings.json`.
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

- [ ] **Stop using hardcoded line ranges for `--help` in the tooling.**
  `deploy.sh` prints `sed -n '2,33p' "$0"` but its header ends at line 35, so
  the last two help lines are truncated. `tools/install-hooks.sh` uses
  `sed -n '3,17p'` against a header ending at 16, so `--help` leaks the
  `set -u` line into the output. Replace with a sentinel (e.g. stop at the first
  non-comment line, or a `__HELP__` marker) so the help text cannot drift out of
  sync with the header.
- [ ] **Accept that the `rm` guard alias is only a speed bump.** `merged/.bash_aliases`
  sets `alias rm='rm -Iv --one-file-system --preserve-root'`, but `-f` overrides
  `-I` entirely, so `rm -rf` through the alias deletes with no prompt (verified).
  Aliases are also not expanded inside functions, so `pirm`'s own `rm -fv` is
  unaffected either way. Either drop `-f` from the alias to make the guard real,
  or document it as advisory rather than a safety net.
- [ ] **Trim the prompt's fork count.** `__makePS1` forks 8+ processes per
  prompt: `$(command -v git)`, `$(git name-rev)`, `$(git status --porcelain)`,
  two `$(echo | grep | sed)` passes, one `$(echo | sort | uniq | tr)`, `$(jobs -p
  | wc -w)`, and three `$(whoami)` for the screen paths. Cheap wins: use the
  already-exported `$USER` instead of `whoami` and build `SCREEN_PATHS` once at
  load time; consider `git status --porcelain -uno` or gating on
  `$GIT_OPTIONAL_LOCKS`. Also `git name-rev` is deprecated — switch to
  `git rev-parse --abbrev-ref HEAD`.
- [ ] **Handle `PROMPT_COMMAND` as an array on bash >= 5.1.** The append guard in
  `merged/.bashrc` assumes the scalar form. With an array, `"${PROMPT_COMMAND}"`
  reads element 0 only and the assignment writes a string into index 0, leaving
  later elements orphaned (verified: `[0]="__makePS1;a" [1]="b"`). Low impact
  today since nothing in the repo sets the array, but the intent is not
  expressed.
- [ ] **Expand `merged/.vimrc`.** Four lines today: no `set hidden`, no
  clipboard, no `undofile`, no `termguicolors`, and an unconditional `syntax on`
  that is slow on large files. It deploys to every bash host, so this is a
  cheap win for the whole fleet.
- [ ] **Make the VS Code settings portable**: split shared settings from
  machine-specific SSH paths, usernames, and host aliases (e.g. a
  `settings.local.json` template or documented patch step).
- [ ] **Guard optional utilities in the startup files.** `FQDN=$(hostname -f)`
  (`merged/.bashrc`, `merged-qnap/.bashrc`) runs unguarded at every shell start
  and is embedded in the terminal title; fall back to `hostname` when `-f` is
  unsupported (older busybox): `FQDN=$(hostname -f 2>/dev/null) || FQDN=$(hostname)`.
  Same treatment for `whoami`/`id -un`/`basename` where used in the prompt.
- [ ] **Improve history defaults**: `HISTTIMEFORMAT`, `shopt -s lithist`,
  `cmdhist` for multiline commands (remember: QNAP runs bash 3.2, so no
  `HISTTIMEFORMAT` features that require newer bash).
- [ ] Add a top-level workspace README describing the independent repositories
  and their common development commands.

## Repository hygiene additions (found 2026-10-01 review)

- [ ] **`.gitattributes` pins `eol=lf` for most config but not all.** `*.jsonc`,
  `terminator/config` (TOML), `.gitignore`, `.gitleaks.toml` and
  `AGENTS.md`-adjacent dotfiles fall back to `* text=auto`, which normalises in
  the index but does not guarantee LF in the worktree. Shell files already
  "choke on CRLF" per the file's own comment; add the remaining tracked config
  extensions for consistency.
- [ ] **`vscode/wsl-ssh.bat` is unchecked and unconstrained.** It is the only
  Windows-executed script in the repo, gets no syntax pass from
  `tools/validate.sh` (it is not in `is_shell_file`), has no `eol=crlf` entry in
  `.gitattributes` — it ships LF today, which `cmd.exe` mostly tolerates but not
  reliably — and `install-hooks.sh`/`validate.sh` cannot catch a typo in it.
  Add a CRLF pin and at least a `git check-attr` assertion.
- [ ] **`opencode/install.sh` fetches over the network with no integrity check.**
  It runs `npm install -g opencode-ai` unpinned (latest at install time) and
  curls `SKILL_BASE/$s/SKILL.md` with no checksum, so the same commit produces
  different results on different days and a compromised endpoint is
  indistinguishable from a good run. Pin the npm version; record the expected
  SKILL.md hashes.
- [ ] **`merged/.bash_logout` is unguarded but so is `.profile`/`bash_profile`
  ordering.** `.bash_profile` sources `.bashrc` then `.profile`, and on QNAP
  the `.bash_profile` variant is not deployed — worth a line in AGENTS.md so
  the next person does not "fix" `.bash_profile` for a host that never reads it.

## CI and repository hygiene

- [ ] **CI workflow** running `tools/validate.sh` on push/PR (syntax, vimrc,
  drift, newlines, JSON, gitleaks). Install `shellcheck` in CI so that pass
  stops being a local SKIP.
- [ ] **Install `shellcheck` locally** (`tools/install-tools.sh`); until then
  `tools/validate.sh` reports that pass as SKIP.
- [ ] **Tests for the deployment matrix** (QNAP, Alpine, OpenWrt/ash): run
  `deploy.sh --dry-run` against a synthetic `~/.ssh/config` and assert each host
  resolves to the right manifest, without touching a real host.
- [ ] **`tools/validate.sh`: skip `*.jsonc`.** `json_file()` matches only
  `*.json|*.sublime-settings`, so `opencode/opencode.jsonc` — the file with the
  most config in the repo — is never parsed, despite the help text advertising a
  "JSON / JSONC" check. Add `*.jsonc`.
- [ ] **`tools/validate.sh`: no ash/dash syntax pass on `merged-openwrt/`.**
  `bash -n` passes on ash files, so a bash-only construct (`[[ ]]`, arrays,
  `local -a`, `$'...'`) in the deliberately ash-compatible openwrt set passes CI
  and then breaks on the MIPS box. That directory exists precisely to be
  ash-safe, so gate a `busybox ash -n` (or `dash -n`) pass on the command being
  present.
- [ ] **`tools/validate.sh`: syntax-check `terminator/config`.** It is TOML and
  gets no check at all; `sublime-text/*.sublime-keymap` is JSON-shaped but also
  misses the `*.json` glob.
- [ ] **Batch the SSH round-trips in `deploy.sh`.** Per Debian host it makes 21:
  `push` calls `backup_remote` (1 ssh), then scp, then a separate chmod ssh, for
  each of 7 files, plus the `probe_os`. Move the backup to one call per host and
  fold the `chmod` into the scp/pipe step. The backup-pruning logic is also
  duplicated between `prune_backups` and the `backup_remote` heredoc — a shared
  helper would halve it.
- [ ] **Refresh the stale `.gitleaks.toml` header comment.** It still references
  `gitleaks detect --pipe`, the subcommand removed in gitleaks 8.19.
- [ ] **Make `core.hooksPath` the documented default.** `tools/install-hooks.sh`
  supports `--hooks-path`, but it is not set in this clone, so a fresh clone
  depends on the copy step running by hand.
- [ ] Confirm generated output (coverage, `*.tsbuildinfo`) is ignored in the
  sibling repositories too — this repo's `.gitignore` covers only this tree.

## Deployment order

- [ ] Push the ANSI-only (no `tput`) `.bashrc` to `m9`, `alp`, `rui`, `fata`,
  `zot` — they still run the older tput-gated version.
- [ ] **Before the new `.bashrc` reaches a host, add the gateway URL to that
  host's `~/.bash_aliases_local`** (one line, per host):
  `export NINEROUTER_URL="http://9router.m9.home.arpa"`. The shared `.bashrc`
  no longer hardcodes it, so a host that skips this loses `NINEROUTER_URL` and
  `opencode` fails on an empty `baseURL`. qnap and alpine already get it from
  their tracked local files; the debian hosts need it by hand.
