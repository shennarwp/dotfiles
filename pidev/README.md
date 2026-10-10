# pidev — pi (pi.dev) wired to 9router

Set up [pi](https://pi.dev) to talk to the 9router gateway, the same endpoint
[`opencode/`](../opencode/) uses. Drop this on a new machine and pi has the
same model catalog opencode has.

| File | Purpose |
|---|---|
| [`install.sh`](install.sh) | idempotent installer: env vars, `models.json`, extension |
| [`models.json`](models.json) | static fallback — the `oc-free` provider plus a fixed `9router` list |
| [`extension/9router.ts`](extension/9router.ts) | provider extension that discovers models live from `/v1/models` |

## 1. Install

```bash
./install.sh            # extension mode (recommended)
./install.sh --static   # models.json only, no extension
```

Both modes are safe to re-run. `install.sh` merges into an existing
`models.json` rather than replacing it, so other providers survive; pass
`--force-models` to replace it outright, and `--no-models` to leave it alone.

Other options: `--help`, and `PI_CODING_AGENT_DIR` to target a non-default
agent directory (default `~/.pi/agent`).

## 2. Environment

Same two variables as opencode, both per-host, both in `~/.bash_aliases_local`
(`chmod 600`), which `merged/.bashrc` sources:

```bash
export NINEROUTER_URL="http://<gateway-host>"             # per-host endpoint
export NINEROUTER_KEY="sk-..."                        # Dashboard → Keys
```

`install.sh` prompts for the key on a TTY and appends it there. If you skip
it, pi can ask for it itself with `/login 9router` — the extension registers
that provider with an api-key login backed by `NINEROUTER_KEY`.

Nothing is hardcoded in `models.json` or the extension: `baseUrl` is
`${NINEROUTER_URL}/v1` and `apiKey` is `${NINEROUTER_KEY}`, so switching
endpoint or key is one edit in the local layer.

**Caveat on qnap and alpine:** `deploy.sh` *does* overwrite
`~/.bash_aliases_local` on those two hosts from the tracked
`merged-{qnap,alpine}/.bash_aliases_local`, which carries the URL but must
never carry the key. See [FIXME.md](../FIXME.md).

## 3. Which mode

**Extension mode (default).** `9router` models are fetched from
`$NINEROUTER_URL/v1/models` at startup and carry real per-model metadata:

```
combo                    ctx=128000   out=32768  input=text+image  reasoning=false
gemini/gemini-3.8-flash  ctx=1048576  out=65536  input=text+image  reasoning=true
cf/@cf/openai/gpt-oss-120b ctx=128000 out=64000  input=text         reasoning=true
```

The gateway's catalog is whatever accounts are configured on that box, and it
changes when you add or remove one. A static `models.json` cannot track that,
and entries without `contextWindow`/`maxTokens` make pi guess — which
under-reports a 1M-context Gemini and skews `/session` cost. If a refresh
fails, the extension keeps the previous list rather than dropping to zero.

**Static mode (`--static`).** No extension; a fixed list in `models.json`.
Simpler, no discovery, but you edit the file by hand when the gateway changes.

In extension mode `install.sh` removes the static `9router` entry from
`models.json` on purpose: pi composes `models.json` *above* a registered
provider, so a stale static list would override the discovered one.

**The `oc-free` provider stays static either way.** Those `oc/*` models are
not in `/v1/models` — they are a separate upstream catalog proxied by the same
gateway — so they are declared in `models.json` and left alone by the
extension.

## 4. Verify

```bash
source ~/.bashrc                      # pick up the exports
pi --list-models | grep 9router       # extension mode: 9 models discovered
curl "$NINEROUTER_URL/api/health" -H "Authorization: Bearer $NINEROUTER_KEY"
# {"ok":true}
```

Then `/model` inside pi to pick one. After editing `models.json` or the
extension in a live session, `/reload`.

Set a default with `Ctrl+S` in `/model`, or in `~/.pi/agent/settings.json`:

```json
{ "defaultProvider": "9router", "defaultModel": "gemini/gemini-3.8-flash" }
```

## 5. Try it before installing

```bash
pi -e ./extension/9router.ts
```

## 6. Uninstall

```bash
rm ~/.pi/agent/extensions/9router.ts
# then re-run ./install.sh --static to put a fixed 9router list back in models.json
```

## 7. Troubleshooting

**No models under `9router`.** The provider needs auth before its models show
up. Check `NINEROUTER_KEY` is exported in the process that starts pi, or run
`/login 9router`. `curl "$NINEROUTER_URL/v1/models"` by hand separates
"gateway unreachable" from "no key".

**Extension loaded but catalog empty.** The endpoint may be up while pi runs
offline (`allowNetwork: false`), in which case the previous list is kept and
nothing is fetched. Restart with network.

**A model disappeared after adding an account.** Expected: the list *is* the
gateway's list. Run `/reload` or restart pi to re-discover.

**Requests rejected by the gateway.** `openai-completions` is the API the
gateway speaks; both `baseURL`s in the opencode config use the same
compatibility setting. If a model rejects a field, it is a gateway-side
capability, not pi — check `/v1/models` `capabilities` for that id.
