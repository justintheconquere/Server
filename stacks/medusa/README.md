# Medusa — first run and agent access

1. Fill in `.env` (three generated secrets).
2. `docker compose up -d` — the server migrates the database on
   start. First build compiles the admin; give it a few minutes.
3. Create the admin user:
   `docker compose exec server npx medusa user -e you@example.com -p '<password>'`
   then sign in at `http://ufo:9000/app`.
4. In the admin: Settings → API tokens / publishable keys. The
   storefront (when built) uses a publishable key against the
   Store API (`/store/...`); automation uses the Admin API
   (`/admin/...`) with a token.

**Agents:** everything is REST. Hermes/n8n can read and manage
products, orders, and customers through the Admin API with a
token scoped to this store — treat that token like a wallet key
(it can refund and edit), keep it in the stack `.env` family, and
gate order-changing calls behind approvals the same way as n8n's
customer-facing sends.

**Payments:** Stripe is the standard Medusa payment provider
(module added to the project when the storefront lands). No
processor is configured by this stack.

**Leaving later:** the whole store is the Postgres database plus
this project folder — `pg_dump` + the repo is a complete exit,
and the catalog exports through the Admin API.
