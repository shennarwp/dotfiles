# dotfiles

Shared bash configuration for all managed hosts, with per-host overrides where needed.

## Structure

```
merged/                 single source of truth — deployed to most hosts
├── .bashrc             fancy prompt, fastfetch banner, opencode/Go paths
├── .bash_aliases       union of all aliases (git, docker, fetch scripts, etc.)
├── .bash_functions     helper functions (most, vim, multitail, etc.)
├── .bash_profile       sources .profile
├── .profile            sources .bashrc, adds ~/bin and ~/.local/bin
├── .bash_logout        reset terminal on logout
└── .vimrc              line numbers, syntax, spaces-not-tabs

merged-qnap/            QNAP TS-219 (ARMv5, bash 3.2, no git/tput/hostid)
├── .bashrc             ANSI-only prompt (no jobs/screen blocks), neofetch banner
├── .bash_aliases       shared aliases + QNAP ls override (no --color on busybox)
├── .bash_functions     shared functions
└── .bash_logout        reset terminal on logout

merged-gpd/             Alpine 3.24 (no ncurses, apk-based)
└── .bash_aliases       shared aliases + apk uu/uug/aai/aas overrides

merged-omega/           OpenWrt 18.06 MIPS (ash, busybox-only)
├── .bash_aliases       deliberately ash/busybox-compatible set (no GNU flags)
└── .profile            sources the omega aliases, pfetch banner, PATH

windows-terminal/       portable Windows Terminal settings (Monokai Remastered)
├── settings.json       sanitized, portable config (theme + fonts + profiles)
├── schemes/            extracted Monokai Remastered scheme + ANSI mapping
└── README.md           stock location, apply steps, font links

vscode/                 Windows VS Code config for remote development over WSL
├── settings.json       editor settings, theme, remote SSH config
├── wsl-ssh.bat         helper that proxies SSH calls through WSL
└── README.md           deploy instructions and notes

.gitleaks.toml          secret-scan config (used by the pre-commit hook)
```

## Hosts

| Host | SSH alias | OS | Arch | Notes |
|------|-----------|-----|------|-------|
| x270 | (local) | Debian 13 trixie (WSL) | x86_64 | dev machine, fastfetch 2.40.4-debug |
| m9 | `m9` | Debian 12 bookworm | x86_64 | M900tiny |
| alp | `alp` | Debian 12 bookworm | x86_64 | alpinesky |
| rui | `rui` | Ubuntu 24.04 | aarch64 | ruipryux |
| fata | `fata` | Debian 11 bullseye | x86_64 | fastfetch polyfilled .deb |
| zot | `zot` | Debian 13 trixie | x86_64 | fastfetch 2.40.4-debug |
| qnap | `qnap` | QTS 4.3.3 (TS-219) | armv5tel | no tput/git/jobs, neofetch |
| gpd | `gpd` | Alpine 3.24 | x86_64 | requires `apk add bash bash-completion ncurses fastfetch` |
| omega | `omg` | OpenWrt 18.06 | MIPS | ash/busybox, pfetch, no fastfetch |
| zro | `zro` | (undocumented) | — | — |

## Deployment

Manual scp/rsync per host. Each host's dotfiles are installed to `~/` in the respective home:

- **Standard hosts** (m9, alp, rui, fata): copy `merged/` files directly
- **Local x270**: copy `merged/` files to `~/`
- **QNAP**: copy `merged-qnap/` files (QNP-specific .bashrc + shared aliases/functions)
- **gpd**: copy `merged/` files + `merged-gpd/.bash_aliases` (apk overrides)
- **omega**: copy `merged-omega/.bash_aliases` + `merged-omega/.profile` (its own ash-compatible set)

Connection details live in local `~/.ssh/config`; only host alias names are referenced here.

## Secret scanning

`gitleaks` (at `~/bin/gitleaks`) runs from the `.git/hooks/pre-commit` hook on every
commit via `gitleaks detect --pipe --config .gitleaks.toml`. No secrets, ports, IPs,
or usernames are tracked in this repo.

## Legacy

Per-host folders (`alpinesky/`, `m9/`, `ruipryux/`, `x270/`, `x270-cygwin/`) were removed in September 2026 after consolidation into the merged set.

## Aliases quick reference

| Alias | Command |
|-------|---------|
| `uu` | system upgrade (apt/apk per host) |
| `gl` / `glg` / `gpl` / `gplo` | git log helpers |
| `dc` / `dco` / `dcip` | docker compose |
| `nf` / `fh` / `uf` | neofetch / fastfetch / ufetch |
| `spd` | Cloudflare 100 MB speed test (MB summary) |
| `sb` | Sublime Text (WSL) |
| `tq` | `~/torque` |
