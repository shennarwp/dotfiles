#!/usr/bin/env bash
# HELP-BEGIN
#
# tools/install-hooks.sh — wire the tracked hooks in .githooks/ into this clone.
#
# .git/hooks/ is not tracked by git, so the hooks live in .githooks/ and are
# installed from here. Re-run this after a fresh clone or after moving the repo.
#
# Usage:
#   tools/install-hooks.sh              set core.hooksPath=.githooks (default)
#   tools/install-hooks.sh --copy       copy hooks into .git/hooks instead
#   tools/install-hooks.sh --uninstall  remove installed hooks / clear the config
#
# hooks-path mode needs no copying, so the tracked hooks cannot go stale against
# a working-tree edit. --copy is kept for setups that cannot set core.hooksPath
# (older git, or a shared .git directory); copies are marked with a
# "managed-by: tools/install-hooks.sh" line, and --uninstall only deletes copies
# carrying that marker, so a hand-written hook is backed up
# (hooks/TIMESTAMP.bak) instead of being clobbered.
# HELP-END

set -u

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR" || exit 1

GIT_DIR="$(git rev-parse --git-dir 2>/dev/null)" || {
    echo "install-hooks.sh: not inside a git repository" >&2
    exit 1
}
HOOKS_SRC="$REPO_DIR/.githooks"
MARKER="# managed-by: tools/install-hooks.sh"
MODE=hooks-path
STAMP="$(date +%Y%m%d-%H%M%S)"

while [ $# -gt 0 ]; do
    case "$1" in
        --copy)      MODE=copy; shift ;;
        --hooks-path) MODE=hooks-path; shift ;;
        --uninstall) MODE=uninstall; shift ;;
        -h|--help)    
            awk '/^# HELP-BEGIN$/{flag=1;next} /^# HELP-END$/{flag=0} flag {sub(/^# ?/, ""); print}' "$0"
            exit 0 ;;
        *) echo "install-hooks.sh: unknown option: $1 (see --help)" >&2; exit 2 ;;
    esac
done

if [ ! -d "$HOOKS_SRC" ]; then
    echo "install-hooks.sh: no $HOOKS_SRC directory" >&2
    exit 1
fi

list_hooks() {
    for h in "$HOOKS_SRC"/*; do
        [ -f "$h" ] || continue
        printf '%s\n' "$(basename "$h")"
    done
}

case "$MODE" in
    hooks-path)
        git config core.hooksPath "$HOOKS_SRC"
        echo "core.hooksPath = $HOOKS_SRC"
        echo "hooks active: $(list_hooks | tr '\n' ' ')"
        for name in $(list_hooks); do
            if [ -f "$GIT_DIR/hooks/$name" ] && grep -qF "$MARKER" "$GIT_DIR/hooks/$name" 2>/dev/null; then
                echo "note: stale copy $GIT_DIR/hooks/$name is now ignored (--uninstall removes it)"
            fi
        done
        ;;
    uninstall)
        git config --unset core.hooksPath 2>/dev/null
        for name in $(list_hooks); do
            dst="$GIT_DIR/hooks/$name"
            [ -f "$dst" ] || continue
            if grep -qF "$MARKER" "$dst"; then
                rm -f "$dst"
                echo "removed $dst"
            else
                echo "kept $dst (not managed by this repo)"
            fi
        done
        echo "core.hooksPath unset"
        ;;
    copy)
        for name in $(list_hooks); do
            src="$HOOKS_SRC/$name"
            dst="$GIT_DIR/hooks/$name"
            if [ -e "$dst" ] && ! grep -qF "$MARKER" "$dst" 2>/dev/null; then
                cp "$dst" "$GIT_DIR/hooks/${name%.sample}.${STAMP}.bak"
                echo "backed up existing $dst -> $GIT_DIR/hooks/${name%.sample}.${STAMP}.bak"
            fi
            # keep the marker near the top, but never above a shebang (git
            # executes hooks directly, so line 1 must stay the interpreter)
            {
                IFS= read -r first < "$src" || first=""
                case "$first" in
                    '#!'*) printf '%s\n%s\n' "$first" "$MARKER"; tail -n +2 "$src" ;;
                    *)     printf '%s\n%s\n' "$MARKER" "$first"; cat "$src" ;;
                esac
            } > "$dst"
            chmod +x "$dst"
            echo "installed $dst"
        done
        echo
        echo "run: git commit -m '...'   (hook runs tools/validate.sh --hook)"
        ;;
esac
