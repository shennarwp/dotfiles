# pidev — pi (pi.dev) wired to 9router

Set up [pi](https://pi.dev) to talk to the 9router gateway, the same endpoint
[`opencode/`](../opencode/) uses. Drop this on a new machine and pi has the
same model catalog opencode has.

| File | Purpose |
|---|---|
| [`install.sh`](install.sh) | idempotent installer: env vars, `models.json` |
| [`models.json`](models.json) | the 19-model `9router` list — same set as `../opencode/opencode.jsonc` |

## 1. Install

```bash
./install.sh
```

Safe to re-run. `install.sh` merges into an existing `models.json` rather than
replacing it, so other providers survive; pass `--force-models` to replace it
outright, and `--no-models` to leave it alone.

Other options: `--help`, and `PI_CODING_AGENT_DIR` to target a non-default
agent directory (default `~/.pi/agent`).

## 2. Environment

Same two variables as opencode, both per-host, both in `~/.bash_aliases_local`
(`chmod 600`), which `merged/.bashrc` sources:

```bash
export NINEROUTER_URL="http://<gateway-host>"   # per-host endpoint
export NINEROUTER_KEY="sk-..."                  # Dashboard → Keys
```

`install.sh` prompts for the key on a TTY and appends it there.

Nothing is hardcoded in `models.json`: `baseUrl` is `${NINEROUTER_URL}/v1` and
`apiKey` is `${NINEROUTER_KEY}`, so switching endpoint or key is one edit in
the local layer.

**Caveat on qnap and alpine:** `deploy.sh` *does* overwrite
`~/.bash_aliases_local` on those two hosts from the tracked
`merged-{qnap,alpine}/.bash_aliases_local`, which carries the URL but must
never carry the key. See [FIXME.md](../FIXME.md).

## 3. Models

Static-only. `models.json` declares the same 19 models as
[`../opencode/opencode.jsonc`](../opencode/opencode.jsonc), all with
`reasoning: true`. Edit both files together to change the set.

No extension, no discovery: the picker is exactly what `models.json` says. The
gateway may serve more models than the 19 declared here; add them by hand if
you want them visible in pi.

## 4. Verify

```bash
source ~/.bashrc                      # pick up the exports
pi --list-models | grep 9router       # expect 19 models (same as opencode)
curl "$NINEROUTER_URL/api/health" -H "Authorization: Bearer $NINEROUTER_KEY"
# {"ok":true}
```

Then `/model` inside pi to pick one. After editing `models.json` in a live
session, `/reload`.

Set a default with `Ctrl+S` in `/model`, or in `~/.pi/agent/settings.json`:

```json
{ "defaultProvider": "9router", "defaultModel": "ag/gemini-3.8-flash" }
```

## 5. Uninstall

```bash
rm ~/.pi/agent/models.json
```

## 6. Troubleshooting

**No models under `9router`.** The provider needs auth before its models show
up. Check `NINEROUTER_KEY` is exported in the process that starts pi.
`curl "$NINEROUTER_URL/v1/models"` by hand separates "gateway unreachable"
from "no key".

**A model disappeared after adding an account.** Nothing is auto-discovered.
The picker stays at the 19 models declared in this repo. Edit `models.json`
(and `../opencode/opencode.jsonc`) together to change the set, then `/reload`.

**Requests rejected by the gateway.** `openai-completions` is the API the
gateway speaks; the opencode config uses the same compatibility setting. If a
model rejects a field, it is a gateway-side capability, not pi — check
`/v1/models` `capabilities` for that id.
