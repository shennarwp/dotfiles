#!/usr/bin/env bash
#
# tools/install-tools.sh — install the optional tools tools/validate.sh uses.
#
#   gitleaks    required for the secret scan (pre-commit hook); report SKIP
#               without it
#   shellcheck  optional lint pass; report SKIP without it
#
# Both land in ~/bin (gitleaks) or come from the distro (shellcheck). Nothing is
# installed into the repo, and nothing here is required to deploy dotfiles.
#
# Usage:
#   tools/install-tools.sh              install gitleaks (and shellcheck if apt)
#   tools/install-tools.sh --gitleaks   gitleaks only (no sudo needed)
#   tools/install-tools.sh --check      report what is present, install nothing

set -u

GITLEAKS_VERSION="${GITLEAKS_VERSION:-8.30.1}"
BIN_DIR="$HOME/bin"
ONLY_GITLEAKS=0
CHECK_ONLY=0

while [ $# -gt 0 ]; do
    case "$1" in
        --gitleaks) ONLY_GITLEAKS=1; shift ;;
        --check)    CHECK_ONLY=1; shift ;;
        -h|--help)  sed -n '3,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "install-tools.sh: unknown option: $1 (see --help)" >&2; exit 2 ;;
    esac
done

report() {
    if command -v gitleaks >/dev/null 2>&1; then
        printf 'gitleaks    %s (%s)\n' "$(command -v gitleaks)" "$(gitleaks version 2>/dev/null | head -1)"
    elif [ -x "$BIN_DIR/gitleaks" ]; then
        printf 'gitleaks    %s (%s)\n' "$BIN_DIR/gitleaks" "$("$BIN_DIR/gitleaks" version 2>/dev/null | head -1)"
    else
        printf 'gitleaks    missing\n'
    fi
    if command -v shellcheck >/dev/null 2>&1; then
        printf 'shellcheck  %s (%s)\n' "$(command -v shellcheck)" "$(shellcheck --version | sed -n 's/^version: //p')"
    else
        printf 'shellcheck  missing\n'
    fi
}

install_gitleaks() {
    local os arch
    case "$(uname -s)" in
        Linux)  os=linux ;;
        Darwin) os=darwin ;;
        *) echo "install-tools.sh: unsupported OS $(uname -s) for the gitleaks binary" >&2; return 1 ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64)  arch=x64 ;;
        aarch64|arm64) arch=arm64 ;;
        *) echo "install-tools.sh: unsupported arch $(uname -m)" >&2; return 1 ;;
    esac

    local tmp tarball="gitleaks_${GITLEAKS_VERSION#v}_${os}_${arch}.tar.gz"
    local url="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION#v}/${tarball}"

    mkdir -p "$BIN_DIR" || return 1
    tmp="$(mktemp -d)" || return 1
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp'" EXIT

    echo "fetching $url"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$tmp/$tarball" "$url" || return 1
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$tmp/$tarball" "$url" || return 1
    else
        echo "install-tools.sh: need curl or wget" >&2
        return 1
    fi

    tar xzf "$tmp/$tarball" -C "$tmp" gitleaks || return 1
    install -m 0755 "$tmp/gitleaks" "$BIN_DIR/gitleaks" || return 1
    echo "installed $BIN_DIR/gitleaks ($("$BIN_DIR/gitleaks" version))"
}

install_shellcheck() {
    if command -v shellcheck >/dev/null 2>&1; then
        echo "shellcheck already present: $(command -v shellcheck)"
        return 0
    fi
    if command -v apt >/dev/null 2>&1; then
        echo "installing shellcheck via apt (needs sudo)"
        sudo apt update -y && sudo apt install -y shellcheck
    elif command -v apk >/dev/null 2>&1; then
        sudo apk add shellcheck
    else
        echo "install-tools.sh: no apt/apk here; see https://github.com/koalaman/shellcheck#installing"
        return 1
    fi
}

if [ "$CHECK_ONLY" = 1 ]; then
    report
    exit 0
fi

install_gitleaks || echo "install-tools.sh: gitleaks install failed" >&2
[ "$ONLY_GITLEAKS" = 0 ] && install_shellcheck

echo
report
exit 0
