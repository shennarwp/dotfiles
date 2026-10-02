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
LOCAL_OVERRIDES="${LOCAL_OVERRIDES:-$HOME/.bash_aliases_local}"
RC="${RC:-$HOME/.bashrc}"

# The gateway URL is per-host and is no longer hardcoded anywhere in the repo,
# so recover it from the host-local override layer for the health check below.
if [ -z "${NINEROUTER_URL:-}" ] && [ -f "$LOCAL_OVERRIDES" ]; then
    NINEROUTER_URL="$(grep -m1 '^[[:space:]]*export NINEROUTER_URL=' "$LOCAL_OVERRIDES" 2>/dev/null \
        | sed 's/^[^=]*=[[:space:]]*//; s/^["'"'"']//; s/["'"'"']$//')" || true
fi

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

# ── 2. environment ───────────────────────────────────────────────────────
# NINEROUTER_URL and NINEROUTER_KEY are BOTH per-host and BOTH live in
# ~/.bash_aliases_local: the URL is no longer in the tracked merged/.bashrc,
# because hosts off the LAN would carry an internal name that never resolves,
# and appending to ~/.bashrc is undone by the next deploy (deploy.sh copies
# merged/.bashrc over it wholesale).
#
# NOTE: on qnap and alpine, deploy.sh \`push_append\` merges the tracked copy
# into ~/.bash_aliases_local, preserving any host-specific content. The header
# and deploy_mode comment below now reflect this append-vs-overwrite behaviour.

if [ -f "$LOCAL_OVERRIDES" ] && grep -q 'NINEROUTER_KEY' "$LOCAL_OVERRIDES" 2>/dev/null; then
  say "NINEROUTER_KEY already in $LOCAL_OVERRIDES"
else
  if [ -t 0 ]; then
    printf 'Paste 9router API key (Dashboard -> Keys, blank to skip): '
    read -r KEY
    if [ -n "$KEY" ]; then
      {
        printf '\n# 9router API key — secret, per-host.\n'
        printf 'export NINEROUTER_KEY="%s"\n' "$KEY"
      } >>"$LOCAL_OVERRIDES"
      chmod 600 "$LOCAL_OVERRIDES"
      say "added NINEROUTER_KEY to $LOCAL_OVERRIDES"
    else
      say "skipped key — set NINEROUTER_KEY in $LOCAL_OVERRIDES before starting opencode"
    fi
  else
    say "non-interactive: set NINEROUTER_KEY in $LOCAL_OVERRIDES yourself"
  fi
fi

if ! grep -q 'NINEROUTER_URL' "$LOCAL_OVERRIDES" 2>/dev/null; then
  say "NOTE: NINEROUTER_URL not in $LOCAL_OVERRIDES — add it there (see README section 2)"
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
if [ -z "$NINEROUTER_URL" ]; then
  say "NINEROUTER_URL unknown — skipped gateway check (set it in $LOCAL_OVERRIDES)"
elif ! command -v curl >/dev/null 2>&1; then
  say "curl not found, skipped gateway check"
else
  if curl -sf -m 10 "$NINEROUTER_URL/api/health" >/dev/null 2>&1; then
    say "gateway healthy: $NINEROUTER_URL"
  else
    say "WARNING: $NINEROUTER_URL/api/health did not answer — check the URL/VPN"
  fi
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
