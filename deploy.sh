#!/usr/bin/env bash
#
# deploy.sh — deploy dotfiles to all hosts.
#
# Runs from any machine that has ~/.ssh/config with entries for the fleet
# (WSL Debian laptops, or m9 inside the home network). Deploys to the local
# machine's ~/ as well as to every ssh-config host.
#
# OS is probed remotely (os-release ID, alpine/openwrt files, qnap marker),
# which picks the deploy manifest:
#   debian/ubuntu -> merged/            alpine -> merged/ + merged-alpine local
#   openwrt       -> merged-openwrt/    qnap   -> merged-qnap/ + merged aliases
#
# Design notes:
#   - BatchMode + ConnectTimeout => unreachable hosts fail fast, never hang,
#     no interactive password prompts. Failures are reported in a summary and
#     the exit code is non-zero; all other hosts still get deployed.
#   - qnap has no scp -> manifests flag "pipe" to stream files via ssh.
#
# Usage:
#   ./deploy.sh                 deploy everything
#   ./deploy.sh --hosts "m9 alp" deploy only those hosts (still does local)
#   ./deploy.sh --dry-run       show what would be deployed
#   ./deploy.sh --local-only    deploy only to the current machine (no SSH)
#   ./deploy.sh --fail-fast     stop on first unreachable/failing host
#   ./deploy.sh --no-backup     overwrite without saving the old copies first
#   DEPLOY_OS=alpine ./deploy.sh --hosts gpd   force an OS manifest (ssh alias)
#   DEPLOY_OS=openwrt ./deploy.sh --hosts omg  force an OS manifest (ssh alias)
#
# Backups:
#   Before overwriting, existing dotfiles are copied to
#   ~/.dotfiles-backup-YYYYMMDD-HHMMSS/ on the target host (local or remote),
#   matching the manual backups in AGENTS.md. Only the newest BACKUP_KEEP (10)
#   directories are kept. Deployed files are chmod 0644, except
#   .bash_aliases_local which is 0600 since it can hold per-host secrets.

set -u

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DST="$HOME"
SSH_CONFIG="$HOME/.ssh/config"
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=4)
DRY_RUN=0
FAIL_FAST=0
LOCAL_ONLY=0
ONLY_HOSTS=""
EXIT_CODE=0
BACKUP=1
BACKUP_KEEP="${BACKUP_KEEP:-10}"
STAMP="$(date +%Y%m%d-%H%M%S)"

# --- merged/ files installed on standard bash hosts -------------------------
MERGED_FILES=(
    .bashrc .bash_aliases .bash_functions
    .bash_profile .profile .bash_logout .vimrc
)
ALPINE_LOCAL_FILE="merged-alpine/.bash_aliases_local"

# --- argument parsing -------------------------------------------------------
while [ $# -gt 0 ]; do
    case "$1" in
        --hosts)
            if [ $# -lt 2 ]; then
                echo "deploy.sh: --hosts requires a space-separated host list" >&2
                echo "deploy.sh: (see --help)" >&2
                exit 2
            fi
            ONLY_HOSTS="$2"; shift 2 ;;
        --dry-run) DRY_RUN=1; shift ;;
        --fail-fast) FAIL_FAST=1; shift ;;
        --local-only) LOCAL_ONLY=1; shift ;;
        --no-backup) BACKUP=0; shift ;;
        -h|--help)
            sed -n '2,33p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "deploy.sh: unknown option: $1 (see --help)"; exit 2 ;;
    esac
done

# --- helpers -----------------------------------------------------------------
log()  { printf '%s\n' "$*"; }
fail() { printf '  \033[31m[FAIL]\033[0m %s\n' "$*"; }

# mode a deployed file should end up with. .bash_aliases_local is the
# host-local override layer and can carry secrets (e.g. NINEROUTER_KEY), so it
# stays 0600; everything else is an ordinary readable dotfile.
deploy_mode() {
    case "$1" in
        .bash_aliases_local) printf '0600' ;;
        *) printf '0644' ;;
    esac
}

# keep only the newest BACKUP_KEEP backup dirs, newest first by mtime.
# portable: no xargs -r and no seq, because qnap/openwrt are busybox/ash.
prune_backups() {
    local root="$1" i=0 d
    while IFS= read -r d; do
        [ -n "$d" ] || continue
        i=$((i + 1))
        [ "$i" -gt "$BACKUP_KEEP" ] && rm -rf "$d"
    done <<EOF
$(ls -dt "$root"/.dotfiles-backup-* 2>/dev/null)
EOF
}

# copy existing local dotfiles into ~/.dotfiles-backup-$STAMP/ before they are
# overwritten. Skips files that are not there yet, and removes the dir again if
# that left it empty (so a first-ever deploy leaves no clutter).
backup_local() {
    local b="$LOCAL_DST/.dotfiles-backup-$STAMP" f n=0
    for f in "${MERGED_FILES[@]}"; do
        [ -f "$LOCAL_DST/$f" ] || continue
        mkdir -p "$b"
        cp -p "$LOCAL_DST/$f" "$b/$f" && n=$((n + 1))
    done
    if [ "$n" -eq 0 ]; then
        rmdir "$b" 2>/dev/null
    else
        log "    backup: $n file(s) -> ${b##*/}/"
    fi
    # prune unconditionally: old backups must not pile up even on a run that
    # had nothing to save (e.g. a first-ever deploy).
    prune_backups "$LOCAL_DST"
}

# same, on a remote host. $1 = host, rest = destination paths.
backup_remote() {
    local host="$1"; shift
    ssh "${SSH_OPTS[@]}" "$host" '
        stamp="$1"; keep="$2"; shift 2
        b="$HOME/.dotfiles-backup-$stamp"
        n=0
        for d in "$@"; do
            d="${d/#\~/$HOME}"
            [ -f "$d" ] || continue
            mkdir -p "$b" 2>/dev/null || continue
            cp -p "$d" "$b/$(basename "$d")" 2>/dev/null && n=$((n + 1))
        done
        [ "$n" -eq 0 ] && rmdir "$b" 2>/dev/null
        # prune oldest, keeping the newest $keep
        i=0
        for old in $(ls -dt "$HOME"/.dotfiles-backup-* 2>/dev/null); do
            i=$((i + 1))
            [ "$i" -gt "$keep" ] && rm -rf "$old"
        done
        exit 0
    ' _ "$STAMP" "$BACKUP_KEEP" "$@" 2>/dev/null
}

# push one file: scp when host has it, else stream via ssh (qnap).
push() {
    local host="$1" src="$2" dst="$3" pipe="$4"
    if [ "$DRY_RUN" = 1 ]; then
        log "    would deploy ${src#./} -> ${host}:${dst}"
        return
    fi
    if [ "$BACKUP" = 1 ]; then
        backup_remote "$host" "$dst"
    fi
    if [ "$pipe" = 1 ]; then
        cat "$src" | ssh "${SSH_OPTS[@]}" "$host" "mkdir -p \$(dirname '$dst'); cat > '$dst'"
    else
        scp -q "${SSH_OPTS[@]}" "$src" "${host}:${dst}"
    fi
    local mode; mode="$(deploy_mode "${dst##*/}")"
    ssh "${SSH_OPTS[@]}" "$host" "chmod '$mode' '$dst'" 2>/dev/null
}

push_append() {
    local host="$1" src="$2" dst="$3" pipe="$4"
    if [ "$DRY_RUN" = 1 ]; then
        log "    would merge ${src#./} -> ${host}:${dst} (preserving host-local)"
        return 0
    fi
    [ "$BACKUP" = 1 ] && backup_remote "$host" "$dst"
    
    local mode; mode="$(deploy_mode "${dst##*/}")"
    
    if [ "$pipe" = 1 ]; then
        ssh "${SSH_OPTS[@]}" "$host" '
            dst="'"$dst"'"
            tmp="$dst.tmp.$$"
            cat > "$tmp"
            if [ -f "$dst" ]; then
                sed -e "/^# >>> deploy.sh managed/,/^# <<< deploy.sh managed/d" "$dst" > "$dst.head"
            else
                : > "$dst.head"
            fi
            { cat "$dst.head"; printf "\n# >>> deploy.sh managed\n"; cat "$tmp"; printf "# <<< deploy.sh managed\n"; } > "$dst"
            rm -f "$tmp" "$dst.head"
            chmod '"$mode"' "$dst"
        '
    else
        scp -q "${SSH_OPTS[@]}" "$src" "${host}:${dst}.tmp"
        ssh "${SSH_OPTS[@]}" "$host" '
            src="'"${dst}.tmp"'"
            dst="'"$dst"'"
            if [ -f "$dst" ]; then
                sed -e "/^# >>> deploy.sh managed/,/^# <<< deploy.sh managed/d" "$dst" > "$dst.head"
            else
                : > "$dst.head"
            fi
            { cat "$dst.head"; printf "\n# >>> deploy.sh managed\n"; cat "$src"; printf "# <<< deploy.sh managed\n"; } > "$dst"
            rm -f "$src" "$dst.head"
            chmod '"$mode"' "$dst"
        '
    fi
}

# probe a remote host's OS. Returns: debian|ubuntu|alpine|openwrt|qnap|unknown
probe_os() {
    local host="$1"
    ssh "${SSH_OPTS[@]}" "$host" '
        if [ -r /etc/os-release ]; then
            id=$(sed -n "s/^ID=\"\?\([^\" ]*\)\"/\1/p" /etc/os-release | head -1)
            [ -n "$id" ] || id=$(sed -n "s/^ID=\([^ ]*\)/\1/p" /etc/os-release | head -1)
            case "$id" in
                debian|ubuntu|alpine|openwrt) echo "$id"; exit 0 ;;
            esac
        fi
        [ -f /etc/debian_version ] && { echo debian; exit 0; }
        [ -f /etc/alpine-release ] && { echo alpine; exit 0; }
        [ -f /etc/openwrt_release ] && { echo openwrt; exit 0; }
        [ -f /etc/default_config/uLinux.conf ] && { echo qnap; exit 0; }
        echo unknown
    ' 2>/dev/null
}

# deploy a manifest to one remote host; $1=host, $2=manifest name (- = none)
deploy_remote() {
    local host="$1" manifest="$2" pipe=0

    case "$manifest" in
        debian|ubuntu)
            log "  $host [$manifest] -> merged/"
            for f in "${MERGED_FILES[@]}"; do
                push "$host" "merged/$f" "~/$f" 0 || fail "$host: $f"
            done
            ;;
        alpine)
            log "  $host [alpine] -> merged/ + merged-alpine local"
            for f in "${MERGED_FILES[@]}"; do
                push "$host" "merged/$f" "~/$f" 0 || fail "$host: $f"
            done
            push "$host" "$ALPINE_LOCAL_FILE" "~/.bash_aliases_local" 0 || fail "$host: local"
            ;;
        qnap)
            log "  $host [qnap] -> merged-qnap/ + common aliases (streamed)"
            pipe=1
            push "$host" "merged-qnap/.bashrc"         "~/.bashrc"         "$pipe" || fail "$host: .bashrc"
            push "$host" "merged-qnap/.bash_logout"    "~/.bash_logout"    "$pipe" || fail "$host: .bash_logout"
            push "$host" "merged-qnap/.bash_functions" "~/.bash_functions" "$pipe" || fail "$host: .bash_functions"
            push "$host" "merged/.bash_aliases"        "~/.bash_aliases"   "$pipe" || fail "$host: .bash_aliases"
            push "$host" "merged-qnap/.bash_aliases_local" "~/.bash_aliases_local" "$pipe" || fail "$host: .bash_aliases_local"
            ;;
        openwrt)
            log "  $host [openwrt] -> merged-openwrt/"
            push "$host" "merged-openwrt/.bash_aliases" "~/.bash_aliases" 0 || fail "$host: .bash_aliases"
            push "$host" "merged-openwrt/.profile"      "~/.profile"      0 || fail "$host: .profile"
            ;;
        unknown)
            fail "$host: OS unrecognized, skipping"
            return 1
            ;;
    esac
    return 0
}

# deploy merged/ to the local machine
deploy_local() {
    log "local  -> merged/ to $LOCAL_DST"
    if [ "$BACKUP" = 1 ] && [ "$DRY_RUN" = 0 ]; then
        backup_local
    fi
    for f in "${MERGED_FILES[@]}"; do
        if [ "$DRY_RUN" = 1 ]; then
            log "    would deploy merged/$f -> $LOCAL_DST/$f"
        else
            cp "merged/$f" "$LOCAL_DST/$f"
            chmod "$(deploy_mode "$f")" "$LOCAL_DST/$f"
        fi
    done
}

# --- run ---------------------------------------------------------------------
cd "$REPO_DIR" || exit 1
log "== deploying from $REPO_DIR =="

MY_HOST="$(hostname | cut -d. -f1)"

deploy_local

if [ "$LOCAL_ONLY" = 1 ]; then
    log "== local deployment complete; skipping SSH hosts =="
    exit 0
fi

if [ -r "$SSH_CONFIG" ]; then
    # top-level Host aliases from ~/.ssh/config (in file order, no wildcards),
    # stripping CR (config may have CRLF line endings from Windows editors)
    mapfile -t HOSTS < <(
        awk 'tolower($1)=="host"{ for(i=2;i<=NF;i++){ gsub(/\r/,"",$i); if($i !~ /^\*/) print $i } }' "$SSH_CONFIG"
    )
else
    log "no $SSH_CONFIG found; skipping remote hosts"
    HOSTS=()
fi

for host in "${HOSTS[@]}"; do
    if [ -n "$ONLY_HOSTS" ]; then
        case " $ONLY_HOSTS " in
            *" $host "*) ;;
            *) continue ;;
        esac
    fi
    if [ "$host" = "$MY_HOST" ]; then
        log "  $host == local machine, already deployed locally"
        continue
    fi
    log "-> $host"
    os=$(probe_os "$host")
    if [ -z "$os" ]; then
        fail "$host: unreachable, skipping"
        EXIT_CODE=1
        [ "$FAIL_FAST" = 1 ] && break
        continue
    fi
    # allow override via DEPLOY_OS env
    [ -n "${DEPLOY_OS:-}" ] && os="$DEPLOY_OS"
    if ! deploy_remote "$host" "$os"; then
        EXIT_CODE=1
        [ "$FAIL_FAST" = 1 ] && break
    fi
done

if [ "$EXIT_CODE" = 0 ]; then
    log "== all hosts deployed =="
else
    fail "some hosts failed (see above)"
fi
exit "$EXIT_CODE"
