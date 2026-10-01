#!/usr/bin/env bash
# Install the opencode + 9router setup on a fresh machine (WSL or Linux).
#
# Idempotent: safe to re-run. Never writes the API key into a tracked file —
# it goes into your shell rc and into opencode's auth store (both chmod 600).
#
# Usage:  ./install.sh [--force-config]
#
#   --force-config  overwrite an existing ~/.config/opencode/opencode.jsonc

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NINEROUTER_URL="${NINEROUTER_URL:-http://10.147.17.5}"
RC="${RC:-$HOME/.bashrc}"

say() { printf '  %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

FORCE=0
[ "${1:-}" = "--force-config" ] && FORCE=1

# ── 1. opencode binary ────────────────────────────────────────────────
if command -v opencode >/dev/null 2>&1; then
  say "opencode already installed: $(command -v opencode) ($(opencode --version 2>/dev/null))"
elif command -v npm >/dev/null 2>&1; then
  say "installing opencode via npm..."
  npm install -g opencode-ai
else
  die "need opencode installed — see https://opencode.ai/docs/ (or install npm first)"
fi

# ── 2. environment (key is asked for, never stored in this repo) ──────
if ! grep -q 'NINEROUTER_URL' "$RC" 2>/dev/null; then
  cat >>"$RC" <<EOF

# 9router gateway
export NINEROUTER_URL="$NINEROUTER_URL"
EOF
  say "added NINEROUTER_URL to $RC"
else
  say "NINEROUTER_URL already in $RC"
fi

if ! grep -q 'NINEROUTER_KEY' "$RC" 2>/dev/null; then
  if [ -t 0 ]; then
    printf 'Paste 9router API key (Dashboard -> Keys, blank to skip): '
    read -r KEY
    if [ -n "$KEY" ]; then
      printf '\n# 9router API key\nexport NINEROUTER_KEY="%s"\n' "$KEY" >>"$RC"
      say "added NINEROUTER_KEY to $RC"
    else
      say "skipped key — add it manually before starting opencode"
    fi
  else
    say "non-interactive: add NINEROUTER_KEY to $RC yourself"
  fi
else
  say "NINEROUTER_KEY already in $RC"
fi

# ── 3. config ─────────────────────────────────────────────────────────
CFG_DIR="$HOME/.config/opencode"
CFG="$CFG_DIR/opencode.jsonc"
mkdir -p "$CFG_DIR"

if [ -f "$CFG" ] && [ "$FORCE" -eq 0 ]; then
  say "keeping existing $CFG (pass --force-config to overwrite)"
else
  cp "$HERE/opencode.jsonc" "$CFG"
  say "installed $CFG"
fi

# ── 4. gateway reachable? ─────────────────────────────────────────────
if command -v curl >/dev/null 2>&1; then
  if curl -sf -m 10 "$NINEROUTER_URL/api/health" >/dev/null 2>&1; then
    say "gateway healthy: $NINEROUTER_URL"
  else
    say "WARNING: $NINEROUTER_URL/api/health did not answer — check the URL/VPN"
  fi
else
  say "curl not found, skipped gateway check"
fi

# ── 5. 9router skills (optional, only if the repo is reachable) ───────
SKILL_BASE=https://raw.githubusercontent.com/decolua/9router/refs/heads/master/skills
SKILLS="9router 9router-chat 9router-image 9router-tts 9router-stt 9router-embeddings 9router-web-search 9router-web-fetch"
mkdir -p "$CFG_DIR/skill"
for s in $SKILLS; do
  mkdir -p "$CFG_DIR/skill/$s"
  if curl -sf -m 20 -o "$CFG_DIR/skill/$s/SKILL.md" "$SKILL_BASE/$s/SKILL.md" 2>/dev/null; then
    say "skill $s"
  else
    say "skill $s: download failed (offline?) — skipped"
  fi
done

cat <<EOF

Done. Next:
  1. reload your shell:   source "$RC"
  2. verify models:       opencode models | grep -E '^(9router|oc-free)'
  3. start:               opencode

If /models does not list the oc/* models, see README.md ("Known quirks").
EOF
