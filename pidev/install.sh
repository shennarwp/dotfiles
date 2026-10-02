#!/usr/bin/env bash
# Set up pi (pi.dev) to talk to the 9router gateway.
#
# Idempotent: safe to re-run. Never writes the API key into a tracked file —
# it goes into ~/.bash_aliases_local (chmod 600), which deploy.sh does not
# overwrite on the debian hosts.
#
# Two install modes:
#   default    provider extension (live model discovery from /v1/models)
#   --static   plain models.json, no extension, fixed model list
#
# Usage:  ./install.sh [--static] [--no-models] [--force-models]
#
#   --static        use models.json only; do not install the extension
#   --no-models     do not touch models.json (extension still installed)
#   --force-models  replace models.json instead of merging into it
#
# Environment:
#   PI_CODING_AGENT_DIR   pi agent dir (default ~/.pi/agent)

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
MODELS_FILE="$AGENT_DIR/models.json"
EXT_FILE="$AGENT_DIR/extensions/9router.ts"
LOCAL_OVERRIDES="${LOCAL_OVERRIDES:-$HOME/.bash_aliases_local}"
RC="${RC:-$HOME/.bashrc}"

# Recover the gateway URL from the host-local override layer, like opencode's
# installer does. Only the health check and the model listing need it.
NINEROUTER_URL="${NINEROUTER_URL:-}"
if [ -z "$NINEROUTER_URL" ] && [ -f "$LOCAL_OVERRIDES" ]; then
  NINEROUTER_URL="$(grep -m1 '^[[:space:]]*export NINEROUTER_URL=' "$LOCAL_OVERRIDES" 2>/dev/null |
    sed 's/^[^=]*=[[:space:]]*//; s/^["'"'"']//; s/["'"'"']$//')" || true
fi

say() { printf '  %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

STATIC=0
WRITE_MODELS=1
FORCE_MODELS=0
while [ $# -gt 0 ]; do
  case "$1" in
    --static) STATIC=1; shift ;;
    --no-models) WRITE_MODELS=0; shift ;;
    --force-models) FORCE_MODELS=1; shift ;;
    -h|--help) awk 'NR>1 && !/^#/ {exit} NR>1 {sub(/^# ?/, ""); print}' "$0"; exit 0 ;;
    *) die "unknown option: $1 (see --help)" ;;
  esac
done

# ── 1. pi binary ─────────────────────────────────────────────────────────
command -v pi >/dev/null 2>&1 || die "pi not found — install it first (see https://pi.dev)"

# ── 2. environment ───────────────────────────────────────────────────────
# NINEROUTER_URL and NINEROUTER_KEY are BOTH per-host and BOTH live in
# ~/.bash_aliases_local (see ../opencode/README.md section 2 — same gateway).
#
# NOTE: on qnap and alpine, deploy.sh \`push_append\` merges the tracked copy
# into ~/.bash_aliases_local, preserving any host-specific content. The header
# and deploy_mode comment below now reflect this append-vs-overwrite behaviour.

if [ -z "$NINEROUTER_URL" ]; then
  say "NINEROUTER_URL not set — add it to $LOCAL_OVERRIDES:"
  say '  export NINEROUTER_URL="http://9router.m9.home.arpa"'
else
  say "NINEROUTER_URL = $NINEROUTER_URL"
fi

if [ -f "$LOCAL_OVERRIDES" ] && grep -q 'NINEROUTER_KEY' "$LOCAL_OVERRIDES" 2>/dev/null; then
  say "NINEROUTER_KEY already in $LOCAL_OVERRIDES"
elif [ -t 0 ]; then
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
    say "skipped key — set NINEROUTER_KEY in $LOCAL_OVERRIDES, or run /login 9router in pi"
  fi
else
  say "non-interactive: set NINEROUTER_KEY in $LOCAL_OVERRIDES yourself (or use /login in pi)"
fi

# ── 3. models.json ───────────────────────────────────────────────────────
# Merge rather than overwrite: the agent's models.json usually holds other
# providers. With the extension installed, the static `9router` entry is
# dropped — the extension owns that provider id, and pi composes models.json
# overrides ABOVE a registered provider, so a stale static list would win.

if [ "$WRITE_MODELS" = 1 ]; then
  mkdir -p "$AGENT_DIR"
  SRC_MODELS="$HERE/models.json"
  [ "$FORCE_MODELS" = 1 ] && [ -f "$MODELS_FILE" ] && cp -p "$MODELS_FILE" "$MODELS_FILE.bak"

  AGENT_DIR="$AGENT_DIR" SRC_MODELS="$SRC_MODELS" MODELS_FILE="$MODELS_FILE" STATIC="$STATIC" \
  FORCE="$FORCE_MODELS" node -e '
    const fs = require("fs");
    const { SRC_MODELS, MODELS_FILE, STATIC, FORCE } = process.env;
    const isStatic = STATIC === "1";
    const force = FORCE === "1";           // string "0" is truthy: compare, do not coerce
    const incoming = JSON.parse(fs.readFileSync(SRC_MODELS, "utf8"));
    let current = { providers: {} };
    if (!force && fs.existsSync(MODELS_FILE)) {
      try {
        current = JSON.parse(fs.readFileSync(MODELS_FILE, "utf8"));
      } catch (e) {
        console.log(`  ERROR: ${MODELS_FILE} is not valid JSON (${e.message})`);
        console.log("  Fix it, or re-run with --force-models to replace it.");
        process.exit(1);
      }
    }
    current.providers = current.providers || {};
    if (isStatic) {
      // static mode: ship both providers, extension does not exist
      Object.assign(current.providers, incoming.providers);
    } else {
      // extension mode: oc-free is not discoverable via /v1/models, so it stays
      // static here; `9router` comes from the extension.
      if (incoming.providers["oc-free"]) current.providers["oc-free"] = incoming.providers["oc-free"];
      delete current.providers["9router"];
    }
    fs.writeFileSync(MODELS_FILE, JSON.stringify(current, null, 2) + "\n");
    const names = Object.keys(current.providers);
    console.log(`  models.json -> ${MODELS_FILE}`);
    console.log(`  providers: ${names.length ? names.join(", ") : "(none)"}`);
  '
else
  say "skipping models.json (--no-models)"
fi

# ── 4. provider extension ────────────────────────────────────────────────
if [ "$STATIC" = 1 ]; then
  say "static mode: not installing the extension"
else
  mkdir -p "$AGENT_DIR/extensions"
  cp "$HERE/extension/9router.ts" "$EXT_FILE"
  say "extension -> $EXT_FILE"
fi

# ── 5. gateway reachable? ────────────────────────────────────────────────
if [ -z "$NINEROUTER_URL" ]; then
  say "NINEROUTER_URL unknown — skipped gateway check"
elif ! command -v curl >/dev/null 2>&1; then
  say "curl not found, skipped gateway check"
else
  KEY="$(grep -m1 '^[[:space:]]*export NINEROUTER_KEY=' "$LOCAL_OVERRIDES" 2>/dev/null |
    sed 's/^[^=]*=[[:space:]]*//; s/^["'"'"']//; s/["'"'"']$//')" || true
  if [ -n "$KEY" ]; then
    BODY="$(curl -sf -m 15 "$NINEROUTER_URL/v1/models" -H "Authorization: Bearer $KEY" 2>/dev/null)" || BODY=""
    if [ -z "$BODY" ]; then
      say "WARNING: $NINEROUTER_URL/v1/models did not answer — check the URL/VPN"
    else
      say "gateway healthy: $NINEROUTER_URL"
      printf '%s' "$BODY" | node -e '
        let raw = "";
        process.stdin.on("data", (c) => (raw += c));
        process.stdin.on("end", () => {
          const data = JSON.parse(raw).data || [];
          console.log(`  ${data.length} model(s) offered:`);
          for (const m of data) console.log(`    ${m.id}`);
          console.log("  note: oc-free/* models are not listed here; they stay in models.json");
        });
      '
    fi
  else
    say "no NINEROUTER_KEY yet — skipped gateway check (pi can also /login 9router)"
  fi
fi

cat <<EOF

Done. Next:
  1. reload your shell:   source "$RC"
  2. list models:          pi --list-models | grep 9router
  3. pick one in pi:      /model
EOF
