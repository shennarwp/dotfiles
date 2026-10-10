# opencode + 9router

Setup for [opencode](https://opencode.ai) on WSL/Linux, routed through the
9router gateway so every model comes from one place.

Target state after following this doc:

- `opencode` on PATH, talking to 9router at `$NINEROUTER_URL`
- 29 chat models discovered from the gateway (gemini / cloudflare / nvidia)
- 4 `oc/*` "OpenCode Free" models visible in the picker
- 8 `9router-*` capability skills installed locally

## Quick start

```bash
./install.sh
source ~/.bashrc
opencode models | grep -E '^(9router|oc-free)'
opencode
```

`install.sh` is idempotent — re-run it any time. It never writes the API key
into this repo; the key goes into `~/.bashrc` and opencode's auth store only.

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
export NINEROUTER_URL="http://<gateway-host>"             # per-host endpoint
export NINEROUTER_KEY="sk-..."                        # Dashboard → Keys
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

It defines two providers, both pointing at the same gateway:

| Provider key | Label in UI | Models | Source |
|---|---|---|---|
| `9router` | 9Router | auto-discovered | `GET /v1/models` |
| `oc-free` | OpenCode Free | 4, declared by hand | see "Known quirks" |

Two config details worth keeping:

- `"apiKey": "{env:NINEROUTER_KEY}"` — the key is read from the environment,
  never stored in the config file.
- `"cacheTTL": 300000` on `9router` — 5 minutes. The discovery plugin otherwise
  caches the model list for 3 hours, so newly connected accounts stay invisible.
  Lower it if you add accounts often.

## 4. Models

```bash
opencode models | grep -E '^(9router|oc-free)' | head
```

Expect `9router/*` for every model the gateway currently serves (the count
tracks whatever accounts are configured in the dashboard) and 4 `oc-free/oc/*`.

After changing accounts in the dashboard, discovery is cached. Wait out
`cacheTTL` (5 min) or restart opencode; there is no CLI flush.

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
| chat | `/v1/models` | 29 |
| image | `/v1/models/image` | 14 |
| tts | `/v1/models/tts` | 5 |
| embeddings | `/v1/models/embedding` | 6 |
| stt | `/v1/models/stt` | 5 |
| web search | `/v1/models/web` | 0 — not connected |
| image-to-text | `/v1/models/image-to-text` | 0 — not connected |

Model counts follow whatever accounts are connected to the gateway, so they
will drift. Re-check with the discovery endpoints above.

## Known quirks

Two non-obvious failure modes, both already worked around in the config above.
Understand them before "fixing" anything that looks broken.

### 9router never lists the `oc/*` models

`curl $NINEROUTER_URL/v1/models | grep -c '"oc/'` returns `0`, even though
`POST /v1/chat/completions` with `oc/space-bunny-free` returns `200`. This is a
server-side gap in 9router, not a misconfiguration — nothing in the dashboard
changes it. Upstream calls it out in the `@haoyiyin/9router` README.

Workaround: declare the four models under a **separate provider key** that does
not start with `9router` (ours is `oc-free`). The discovery plugin only
rewrites providers whose key starts with `9router`:

```js
const providerKeys = Object.keys(provider).filter((k) => k.startsWith("9router"));
// ...
entry.models = discovered ?? {};   // unconditional overwrite
```

So anything declared under `9router` is discarded at startup. `oc-free` is
invisible to the plugin, so those declarations survive.

### The TUI `/models` filters on credentials

A provider can be present in config and visible to `opencode models`, yet be
hidden from the in-app `/models` picker. The picker needs an entry in
opencode's auth store:

```
~/.local/share/opencode/auth.json
```

Add the provider with the same key (both providers here share one gateway and
one key):

```json
"oc-free": { "type": "api", "key": "<same value as NINEROUTER_KEY>" }
```

Quit opencode before editing that file — it can overwrite it on exit. Re-verify
with `opencode providers list`.

The built-in `opencode` provider (OpenCode Zen) also has no credential, so its
own models stay hidden in the picker. That is expected; they are a separate
path that bypasses the gateway.

### Screenshot mismatch

"OpenCode Free" appears in the picker under that label, not as `oc-free` or
`9router` — the `name` field sets the display label. Typing `oc` into the
filter box matches nothing, because the model labels are `Big Pickle`,
`Space Bunny Free`, etc. Clear the filter and scroll for the group label.

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
- If the gateway key ever leaks, rotate it in the 9router dashboard and update
  both places above.

## Files

| File | Purpose |
|---|---|
| `README.md` | this doc |
| `opencode.jsonc` | config to copy into `~/.config/opencode/` |
| `install.sh` | idempotent installer for a fresh machine |
