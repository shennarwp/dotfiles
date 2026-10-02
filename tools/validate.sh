#!/usr/bin/env bash
#
# tools/validate.sh — repository checks for the dotfiles repo.
#
# Checks:
#   1. bash -n over every tracked shell file (dotfile names are spelled out:
#      '*' does not match a leading dot, so `merged-qnap/*.bash*` matches nothing)
#   2. vim -es source check for merged/.vimrc (vimscript, not bash)
#   3. drift: the qnap copies must be byte-identical to their merged/ originals
#   4. every tracked text file ends with exactly one newline
#   5. shellcheck, when installed
#   6. JSON / JSONC parse check (perl JSON::PP; whole-line // comments and
#      trailing commas are stripped first, as VS Code tolerates them)
#   7. gitleaks secret scan — full history by default, staged diff with --hook
#
# Missing optional tools (shellcheck, gitleaks) are reported as SKIP, never as
# failures. Install shellcheck/gitleaks with:  tools/install-tools.sh
#
# Usage:
#   tools/validate.sh                 run every check available
#   tools/validate.sh --hook          pre-commit mode (staged changes only)
#   tools/validate.sh --fix-newlines  append missing trailing newlines, then re-check
#   tools/validate.sh --no-gitleaks   skip the secret scan
#   tools/validate.sh -h | --help     this help

set -u

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR" || exit 1

HOOK_MODE=0
FIX_NEWLINES=0
SKIP_GITLEAKS=0
FAILED=0

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; OFF=$'\033[0m'

pass() { printf '  %sPASS%s  %s\n' "$GREEN" "$OFF" "$*"; }
fail() { printf '  %sFAIL%s  %s\n' "$RED" "$OFF" "$*"; FAILED=1; }
skip() { printf '  %sSKIP%s  %s\n' "$YELLOW" "$OFF" "$*"; }
head_() { printf '\n%s\n' "$*"; }

usage() { sed -n '3,25p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
    case "$1" in
        --hook)         HOOK_MODE=1; shift ;;
        --fix-newlines) FIX_NEWLINES=1; shift ;;
        --no-gitleaks)  SKIP_GITLEAKS=1; shift ;;
        -h|--help)      usage; exit 0 ;;
        *) printf 'validate.sh: unknown option: %s (see --help)\n' "$1" >&2; exit 2 ;;
    esac
done

# --- helpers ------------------------------------------------------------------

# tracked files, NUL-safe (filenames here contain spaces)
tracked_files() {
    while IFS= read -r -d '' f; do
        printf '%s\0' "$f"
    done < <(git ls-files -z)
}

is_shell_file() {
    case "$(basename "$1")" in
        *.sh|pre-commit) return 0 ;;
        .bashrc|.bash_aliases|.bash_aliases_local|.bash_functions|.bash_profile|.bash_logout|.profile) return 0 ;;
        *) return 1 ;;
    esac
}

json_file() {
    case "$1" in
        *.json|*.jsonc|*.sublime-settings) return 0 ;;
        *) return 1 ;;
    esac
}

# binary per .gitattributes (raycast exports): no trailing-newline expectation
is_binary() {
    git check-attr binary -- "$1" 2>/dev/null | grep -q ': binary: set$'
}

find_gitleaks() {
    if command -v gitleaks >/dev/null 2>&1; then
        command -v gitleaks
    elif [ -x "$HOME/bin/gitleaks" ]; then
        printf '%s\n' "$HOME/bin/gitleaks"
    fi
}

# JSON (or JSONC) decode; usage: check_json <file>
check_json() {
    perl -MJSON::PP -e '
        local $/;
        my $c = <STDIN>;
        $c =~ s{^[ \t]*//[^\n]*}{}gm;      # whole-line // comments (JSONC)
        $c =~ s{/\*.*?\*/}{}gs;            # block comments
        $c =~ s!,(\s*[}\]])!$1!gs;         # trailing commas
        eval { JSON::PP->new->decode($c); 1 }
            or do { print(($@ || "invalid JSON"), "\n"); exit 1 };
    ' < "$1" 2>&1
}

# --- 1. bash -n ---------------------------------------------------------------

head_ "bash syntax"
sh_n=0
while IFS= read -r -d '' f; do
    is_shell_file "$f" || continue
    sh_n=$((sh_n + 1))
    if ! out=$(bash -n "$f" 2>&1); then
        fail "$f"
        [ -n "$out" ] && printf '        %s\n' "$out"
    fi
done < <(tracked_files)
[ "$sh_n" -gt 0 ] && pass "bash -n on $sh_n shell file(s)"

# --- 1a. ash/dash -n for openwrt ----------------------------------------------

head_ "ash/dash syntax (merged-openwrt/)"
if command -v busybox >/dev/null 2>&1 && busybox ash -n /dev/null >/dev/null 2>&1; then
    ash_cmd="busybox ash"
elif command -v dash >/dev/null 2>&1; then
    ash_cmd="dash"
else
    skip "neither busybox ash nor dash installed"
fi

if [ -n "${ash_cmd:-}" ]; then
    ash_n=0
    while IFS= read -r -d '' f; do
        case "$f" in
            merged-openwrt/.bash_aliases|merged-openwrt/.profile) ;;
            *) continue ;;
        esac
        ash_n=$((ash_n + 1))
        if ! out=$($ash_cmd -n "$f" 2>&1); then
            fail "$f"
            [ -n "$out" ] && printf '        %s\n' "$out"
        fi
    done < <(tracked_files)
    [ "$ash_n" -gt 0 ] && pass "$ash_cmd -n on $ash_n openwrt file(s)"
fi

# --- 2. vimrc -----------------------------------------------------------------

head_ "vimrc"
if command -v vim >/dev/null 2>&1 && [ -f merged/.vimrc ]; then
    if vim -es -u NONE -N -c 'source merged/.vimrc' -c 'qa!' </dev/null >/dev/null 2>&1; then
        pass "merged/.vimrc sources cleanly"
    else
        fail "merged/.vimrc failed to source in vim"
    fi
else
    skip "vim not installed"
fi

# --- 3. qnap copy drift -------------------------------------------------------

head_ "synced-copy drift (merged/ -> merged-qnap/)"
drift_found=0
for pair in ".bash_functions" ".bash_logout"; do
    src="merged/$pair"
    dst="merged-qnap/$pair"
    if [ ! -f "$src" ] || [ ! -f "$dst" ]; then
        skip "$pair (missing on one side)"
    elif cmp -s "$src" "$dst"; then
        pass "$dst matches $src"
    else
        fail "$dst drifted from $src (fix: cp $src $dst)"
        drift_found=1
    fi
done

# --- 4. trailing newline ------------------------------------------------------

head_ "trailing newline (tracked text files)"
missing=0
while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    [ -s "$f" ] || continue
    is_binary "$f" && continue
    if [ -n "$(tail -c 1 "$f")" ]; then
        if [ "$FIX_NEWLINES" = 1 ]; then
            printf '\n' >> "$f"
            printf '  %sFIX%s   %s (newline appended)\n' "$GREEN" "$OFF" "$f"
        else
            fail "$f (no trailing newline; fix with --fix-newlines)"
        fi
        missing=$((missing + 1))
    fi
done < <(tracked_files)
[ "$missing" -eq 0 ] && pass "all tracked text files end with a newline"

# --- 5. shellcheck ------------------------------------------------------------

head_ "shellcheck"
sc_files=()
while IFS= read -r -d '' f; do
    is_shell_file "$f" && sc_files+=("$f")
done < <(tracked_files)
if command -v shellcheck >/dev/null 2>&1; then
    if out=$(shellcheck -x -S warning "${sc_files[@]}" 2>&1); then
        pass "no warnings in ${#sc_files[@]} file(s)"
    else
        fail "shellcheck findings:"
        printf '%s\n' "$out" | sed 's/^/        /'
    fi
else
    skip "shellcheck not installed (apt install shellcheck)"
fi

# --- 6. JSON ------------------------------------------------------------------

head_ "json / jsonc"
n_json=0
while IFS= read -r -d '' f; do
    json_file "$f" || continue
    n_json=$((n_json + 1))
    if out=$(check_json "$f"); then
        pass "$f"
    else
        fail "$f"
        printf '%s\n' "$out" | sed 's/^/        /'
    fi
done < <(tracked_files)
[ "$n_json" -eq 0 ] && skip "no json files tracked"

# --- 7. gitleaks --------------------------------------------------------------

head_ "gitleaks"
GL="$(find_gitleaks)"
if [ "$SKIP_GITLEAKS" = 1 ]; then
    skip "disabled (--no-gitleaks)"
elif [ -z "$GL" ]; then
    skip "gitleaks not installed (tools/install-tools.sh)"
elif "$GL" git --help >/dev/null 2>&1; then
    # gitleaks >= 8.19: `git` replaces the old detect/protect subcommands
    if [ "$HOOK_MODE" = 1 ]; then
        gl_args=(git --staged)
        gl_what="staged changes"
    else
        gl_args=(git)
        gl_what="git history"
    fi
    if out=$("$GL" "${gl_args[@]}" --no-banner --redact --config .gitleaks.toml . 2>&1); then
        pass "no leaks in $gl_what"
    else
        fail "leaks in $gl_what:"
        printf '%s\n' "$out" | sed 's/^/        /'
    fi
elif "$GL" detect --help >/dev/null 2>&1; then
    # gitleaks < 8.19 legacy CLI
    if [ "$HOOK_MODE" = 1 ]; then
        gl_cmd=(protect --staged)
    else
        gl_cmd=(detect)
    fi
    if out=$("$GL" "${gl_cmd[@]}" --no-banner --redact --config .gitleaks.toml 2>&1); then
        pass "no leaks (legacy gitleaks CLI)"
    else
        fail "leaks found (legacy gitleaks CLI):"
        printf '%s\n' "$out" | sed 's/^/        /'
    fi
else
    skip "unrecognised gitleaks CLI ($GL)"
fi

# --- summary ------------------------------------------------------------------

printf '\n'
if [ "$FAILED" = 0 ]; then
    printf '%svalidate.sh: all checks passed%s\n' "$GREEN" "$OFF"
else
    printf '%svalidate.sh: failures above%s\n' "$RED" "$OFF"
fi
exit "$FAILED"
