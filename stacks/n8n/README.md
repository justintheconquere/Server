# n8n — ops engine

Workflow automation for AssureBay operations: lead intake routing,
renewal reminders, booking follow-ups, daily digests. AI steps are nodes
inside deterministic flows, and **approval steps gate anything
customer-facing** — a workflow pauses and waits for a human OK before an
email or message sends. That rule does not get configured away.

## Deploy

```
cp .env.example .env   # fill in both values (see the warnings inside)
docker network create ufo-net   # once, if it doesn't exist yet
docker compose up -d
```

Then open http://ufo:5678 and **create the owner account immediately** —
the first account created owns the instance.

## Notes

- **Encryption key:** `N8N_ENCRYPTION_KEY` in `.env` encrypts all stored
  credentials. Back it up with the rest of the box secrets. Lose it and
  every stored credential has to be re-entered.
- **Webhooks:** `WEBHOOK_URL` points at the tailnet address. Internal
  triggers (schedules, polling Twenty/Gmail, webhooks from other stacks
  or hosts on the tailnet) work out of the box. Public inbound webhooks
  would need a Cloudflare tunnel route — a deliberate, separate decision,
  never a default.
- **Twenty access:** n8n is on `ufo-net`, so workflows can call the CRM
  at `http://twenty:3000` directly.
- **License:** n8n is source-available (Sustainable Use License) — free
  for AssureBay's internal business use; it can't be resold as a service.
