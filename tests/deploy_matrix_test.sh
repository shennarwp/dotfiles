#!/usr/bin/env bash
#
# tests/deploy_matrix_test.sh — assert each host resolves to the right manifest.
#
# Runs deploy.sh --dry-run against a synthetic ~/.ssh/config so that no real
# host is ever contacted. ssh/scp are shadowed by a shim that records any
# invocation, and the test fails if the shim is ever called.
#
# Usage: tests/deploy_matrix_test.sh

set -u

SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

TMPHOME="$(mktemp -d)"
SHIM_DIR="$(mktemp -d)"
MARKER="$TMPHOME/ssh-was-called"

cleanup() {
    rm -rf "$TMPHOME" "$SHIM_DIR"
}
trap cleanup EXIT

# a synthetic ssh config: fixture aliases only, no real fleet hosts
mkdir -p "$TMPHOME/.ssh"
cat > "$TMPHOME/.ssh/config" <<'CONFIG'
Host t-debian
    HostName 192.0.2.10
    User tester

Host t-qnap
    HostName 192.0.2.11
    User root

Host t-alpine
    HostName 192.0.2.12
    User tester

Host t-openwrt
    HostName 192.0.2.13
    User root

Host *
    ServerAliveInterval 15
CONFIG

# shadow ssh/scp: record the call and refuse to do anything
for prog in ssh scp; do
    cat > "$SHIM_DIR/$prog" <<SHIM
#!/usr/bin/env bash
printf '%s %s\n' "$prog" "\$*" >> "$MARKER"
exit 97
SHIM
    chmod +x "$SHIM_DIR/$prog"
done

RED=$'\033[31m'; GREEN=$'\033[32m'; OFF=$'\033[0m'
pass() { printf '  %sPASS%s  %s\n' "$GREEN" "$OFF" "$*"; }
fail() { printf '  %sFAIL%s  %s\n' "$RED" "$OFF" "$*"; exit 1; }

echo
echo "deployment matrix (synthetic ssh config, dry run)"

run_deploy() {
    env -i \
        PATH="$SHIM_DIR:$PATH" \
        HOME="$TMPHOME" \
        DEPLOY_OS="$1" \
        bash "$REPO_DIR/deploy.sh" --dry-run --hosts "$2" 2>&1
}

# host | forced OS | manifest line deploy.sh must print
while IFS='|' read -r host os manifest; do
    [ -n "$host" ] || continue
    out="$(run_deploy "$os" "$host")" || fail "$host: deploy.sh exited non-zero under --dry-run"
    if printf '%s\n' "$out" | grep -qF -- "$host [$os] -> $manifest"; then
        pass "$host resolves to the $os manifest ($manifest)"
    else
        fail "$host did not resolve to the $os manifest"
        printf '%s\n' "$out" | sed 's/^/        /'
    fi
done <<'FIXTURES'
t-debian|debian|merged/
t-qnap|qnap|merged-qnap/ + common aliases (streamed)
t-alpine|alpine|merged/ + merged-alpine local
t-openwrt|openwrt|merged-openwrt/
FIXTURES

# every fixture host must be discovered from the synthetic config
out="$(run_deploy debian '')"
for host in t-debian t-qnap t-alpine t-openwrt; do
    printf '%s\n' "$out" | grep -qF -- "-> $host" || fail "$host was not read from the synthetic ~/.ssh/config"
done
pass "all fixture hosts discovered from the synthetic ~/.ssh/config"

if [ -e "$MARKER" ]; then
    fail "ssh/scp were invoked during a dry run:"
    sed 's/^/        /' "$MARKER"
fi
pass "no ssh or scp connection opened"

echo
printf '%sdeploy_matrix_test.sh: all checks passed%s\n' "$GREEN" "$OFF"
