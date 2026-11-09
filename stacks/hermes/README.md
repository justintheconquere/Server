# Hermes Agent — chief of staff

Nous Research's self-improving agent: persistent memory, a learning loop
(it writes and improves its own skills), messaging gateways, and an
OpenAI-compatible API. In the agent layer's role split, Hermes is the one
with judgment and memory — it triages, drafts, and remembers context.
Repeatable flows belong to n8n; development belongs to Goose.

## First run — the setup wizard (do this before `up`)

```
cp .env.example .env   # fill in the three values
docker compose run --rm hermes setup
```

The wizard asks for model providers and messaging platforms and writes
them into `./data/.env`. For local models, add Ollama as an
OpenAI-compatible endpoint:

- Base URL: `http://host.docker.internal:11434/v1`
  (Ollama runs natively on the host — there is no Ollama container.)
- API key: any non-empty value (Ollama ignores it)

Then start it:

```
docker compose up -d
```

- Dashboard: http://ufo:9119 (login from this stack's `.env`)
- Gateway API: http://ufo:8642 (key = `API_SERVER_KEY` in `.env`)

## Safety rules

- **Tailnet-only.** Never add a Cloudflare tunnel route or port forward
  for 8642 or 9119. The API key and dashboard password are the only
  things standing between the network and an agent that can act.
- **No Docker socket** in this stack, on purpose. Hermes' Docker
  execution backend would need it; enabling that is a separate decision,
  made knowingly (socket access = root on the host).
- **Approvals:** Hermes drafts; it does not send customer-facing
  messages on its own. Route sends through n8n workflows with approval
  steps, per the standing rule.
- **Data is identity:** `./data` holds config, keys, sessions, skills,
  and memory. It's in the Backrest scope; the image itself is stateless
  and upgrades by pulling a new pinned tag.

## If Paperclip comes later

Paperclip has no model settings of its own — it hires agent runtimes.
It connects to Hermes through its **Hermes Gateway** adapter: API base
URL `http://hermes:8642` (same `ufo-net`) + this stack's
`API_SERVER_KEY`. The Ollama URL lives here, in Hermes' config — which
is why Paperclip's own UI never showed one.
