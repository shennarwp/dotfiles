# opencode + 9router

Setup for [opencode](https://opencode.ai) on WSL/Linux, routed through the
9router gateway so every model comes from one place.

Target state after following this doc:

- `opencode` on PATH, talking to 9router at `$NINEROUTER_URL`
- All 19 9router models visible in the picker
- 8 `9router-*` capability skills installed locally

## Quick start

```bash
./install.sh
source ~/.bashrc
opencode
```

`install.sh` is idempotent — re-run it any time. It never writes secrets into
this repo; `NINEROUTER_KEY` and `KAN_TOKEN` live in `~/.bash_aliases_local`
(`chmod 600`) and are read via `{env:...}` in the config.

## Prerequisites

| Thing | Notes |
|---|---|
| opencode | `npm install -g opencode-ai`, or any other install method |
| A 9router key | Dashboard → Keys. Needed unless the gateway runs with `requireApiKey=false` |
| `curl` | used for the health check and the skills download |
| Reachable gateway | `curl $NINEROUTER_URL/api/health` → `{"ok":true}` |
| Gateway reachable | not required if you override to a VPN/routable address instead |

## 1. Install opencode

```bash
npm install -g opencode-ai
opencode --version
```

Any other install method is fine — only the binary on PATH matters.

## 2. Environment

Both variables are **per-host** and both live in `~/.bash_aliases_local`
(created by `install.sh`, `chmod 600`), which `merged/.bashrc` sources after
`~/.bash_aliases`:

```bash
export NINEROUTER_URL="http://<gateway-host>"   # per-host endpoint
export NINEROUTER_KEY="sk-..."                  # Dashboard → Keys
export KAN_TOKEN="kan_..."                      # kan MCP bearer token
```

Neither is in the tracked `merged/.bashrc`: a host that cannot reach the
gateway should not be carrying its name, and anything appended to `~/.bashrc`
by hand is destroyed on the next deploy (deploy.sh copies `merged/.bashrc`
over it wholesale). The URL used to ship in `merged/.bashrc`; it moved to the
host-local layer so hosts off the LAN do not resolve a name that never
answers. `opencode.jsonc` reads both through `{env:NINEROUTER_URL}` and
`{env:NINEROUTER_KEY}`.

**Caveat on qnap and alpine:** `deploy.sh` *does* overwrite
`~/.bash_aliases_local` on those two hosts from the tracked
`merged-{qnap,alpine}/.bash_aliases_local`, which carries the URL but must
never carry the key. See FIXME.md.

Verify — open a **new** shell first so the exports are picked up:

```bash
curl $NINEROUTER_URL/api/health -H "Authorization: Bearer $NINEROUTER_KEY"
# {"ok":true}
```

`<gateway-host>` is the gateway's **mDNS/LAN** name (port 80), so it works
without a VPN as long as you are on the same network. Off-LAN, point
`NINEROUTER_URL` at a VPN/routable address instead — that also requires the
gateway's peer to be online. To switch, just override `NINEROUTER_URL` in
`~/.bash_aliases_local` — both `baseURL`s in `opencode.jsonc` follow it:

```bash
# expect the gateway's peer ONLINE, then it answers:
ping -c1 <gateway-address>
```

Note the two hosts may not serve the same model set — the set depends on which
accounts are configured on whichever gateway answers.

`NINEROUTER_URL` and `NINEROUTER_KEY` are also the names the 9router skills
expect, so setting them makes every command in those skills work verbatim.

## 3. Config

Copy [`opencode.jsonc`](opencode.jsonc) to `~/.config/opencode/opencode.jsonc`:

```bash
cp opencode.jsonc ~/.config/opencode/opencode.jsonc
```

It defines one provider (`9router`) pointing at the gateway:

| Provider key | Label in UI | Models | Source |
|---|---|---|---|
| `9router` | 9Router | 19, declared by hand | full model list in config |

Two config details worth keeping:

- `"apiKey": "{env:NINEROUTER_KEY}"` — the key is read from the environment,
  never stored in the config file.
- `"cacheTTL": 300000` — 5 minutes. If the gateway model list changes, wait out
  the cache or restart opencode.

## 4. Models

All 19 9router models are declared in [`opencode.jsonc`](opencode.jsonc):
- combo (built‑in)
- ag/gemini-3.8-flash* (4 variants)
- gh/gpt-4o, gh/gpt-4.1, gh/gpt-5.4-nano
- nvidia/nvidia/nemotron-3-ultra-550b-a55b
- cf/@cf/qwen/qwen3.8-27b
- cf/@cf/zai-org/glm-4.7-flash
- deepseek-web/deepseek-v4-pro, deepseek-web/deepseek-v4-flash
- oc/space-bunny-free, oc/big-pickle
- oc/nemotron-3.5-lightning-free (reasoning: true)
- oc/muse-spark-1.3-contributor-free
- oc/deepseek-v4.1-flash-free
- oc/glm-5.3-flash-free

Verify with `opencode models | grep '^9router/' | wc -l` (expect 19).

## 5. Capability skills

The gateway exposes more than chat. Install the skill set so the agent knows
the request shapes:

```bash
for s in 9router 9router-chat 9router-image 9router-tts 9router-stt \
         9router-embeddings 9router-web-search 9router-web-fetch; do
  mkdir -p ~/.config/opencode/skill/$s
  curl -sfo ~/.config/opencode/skill/$s/SKILL.md \
    https://raw.githubusercontent.com/decolua/9router/refs/heads/master/skills/$s/SKILL.md
done
```

`install.sh` does this already. The entry-point skill documents setup and
discovery; the rest cover chat, image, tts, stt, embeddings, web search and web
fetch.

Available on this gateway right now:

| Capability | Endpoint | Models |
|---|---|---|
| chat | `/v1/models` | 19 |
| image | `/v1/models/image` | 14 |
| tts | `/v1/models/tts` | 5 |
| embeddings | `/v1/models/embedding` | 6 |
| stt | `/v1/models/stt` | 5 |
| web search | `/v1/models/web` | 0 — not connected |
| image-to-text | `/v1/models/image-to-text` | 0 — not connected |

Model counts follow whatever accounts are connected to the gateway, so they
will drift. Re-check with the discovery endpoints above.

## Known quirks

The TUI `/models` picker filters on credentials. A provider can be present in
config and visible to `opencode models`, yet hidden from the picker unless it
has an entry in opencode's auth store:

```
~/.local/share/opencode/auth.json
```

Add both providers there:

```json
{
  "9router": { "type": "api", "key": "<same value as NINEROUTER_KEY>" },
  "kan":     { "type": "api", "key": "<same value as KAN_TOKEN>" }
}
```

Quit opencode before editing that file — it can overwrite it on exit. Re-verify
with `opencode providers list`.

## Security

- The API key lives in `~/.bash_aliases_local` (`chmod 600`) and
  `~/.local/share/opencode/auth.json`. Both are outside this repo and outside
  `deploy.sh`'s reach. Keep it that way — `tools/validate.sh` runs gitleaks and
  the repo is public.
- Only the non-secret `NINEROUTER_URL` is tracked, in the per-host override
  layer (`~/.bash_aliases_local` on Debian hosts, `merged-qnap/` and
  `merged-alpine/` tracked copies on those two).
- **Never** put the key in `~/.bashrc`: `deploy.sh` overwrites that file
  wholesale with `merged/.bashrc`, so the key would be lost on the next deploy
  (and `deploy.sh` does not back up first — see FIXME.md).
- The `kan` MCP bearer token is `KAN_TOKEN` in `~/.bash_aliases_local`, read as
  `{env:KAN_TOKEN}` in `opencode.jsonc`. Never commit the literal token — the
  repo is public and `tools/validate.sh` runs gitleaks.
- If the gateway key or the kan token leaks, rotate it and update both places
  above.

## Files

| File | Purpose |
|---|---|
| `README.md` | this doc |
| `opencode.jsonc` | config to copy into `~/.config/opencode/` |
| `cli.json` | CLI theme and session UX settings |
| `install.sh` | idempotent installer for a fresh machine |
