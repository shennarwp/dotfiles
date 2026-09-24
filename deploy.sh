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
#   ./deploy.sh --fail-fast     stop on first unreachable/failing host
#   DEPLOY_OS=alpine ./deploy.sh --hosts gpd   force an OS manifest (ssh alias)
#   DEPLOY_OS=openwrt ./deploy.sh --hosts omg  force an OS manifest (ssh alias)

set -u

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DST="$HOME"
SSH_CONFIG="$HOME/.ssh/config"
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=4)
DRY_RUN=0
FAIL_FAST=0
ONLY_HOSTS=""
EXIT_CODE=0

# --- merged/ files installed on standard bash hosts -------------------------
MERGED_FILES=(
    .bashrc .bash_aliases .bash_functions
    .bash_profile .profile .bash_logout .vimrc
)
ALPINE_LOCAL_FILE="merged-alpine/.bash_aliases_local"

# --- argument parsing -------------------------------------------------------
while [ $# -gt 0 ]; do
    case "$1" in
        --hosts)   ONLY_HOSTS="$2"; shift 2 ;;
        --dry-run) DRY_RUN=1; shift ;;
        --fail-fast) FAIL_FAST=1; shift ;;
        -h|--help)
            sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "deploy.sh: unknown option: $1 (see --help)"; exit 2 ;;
    esac
done

# --- helpers -----------------------------------------------------------------
log()  { printf '%s\n' "$*"; }
fail() { printf '  \033[31m[FAIL]\033[0m %s\n' "$*"; }

# push one file: scp when host has it, else stream via ssh (qnap).
push() {
    local host="$1" src="$2" dst="$3" pipe="$4"
    if [ "$DRY_RUN" = 1 ]; then
        log "    would deploy ${src#./} -> ${host}:${dst}"
        return
    fi
    if [ "$pipe" = 1 ]; then
        cat "$src" | ssh "${SSH_OPTS[@]}" "$host" "mkdir -p \$(dirname '$dst'); cat > '$dst'"
    else
        scp -q "${SSH_OPTS[@]}" "$src" "${host}:${dst}"
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
    for f in "${MERGED_FILES[@]}"; do
        if [ "$DRY_RUN" = 1 ]; then
            log "    would deploy merged/$f -> $LOCAL_DST/$f"
        else
            cp "merged/$f" "$LOCAL_DST/$f"
        fi
    done
}

# --- run ---------------------------------------------------------------------
cd "$REPO_DIR" || exit 1
log "== deploying from $REPO_DIR =="

MY_HOST="$(hostname | cut -d. -f1)"

deploy_local

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