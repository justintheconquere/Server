# SimpleX Directory — first run

The bot is a SimpleX profile in a container. It needs one
interactive pass before it can run unattended:

1. **Build it alone.** The Haskell build is the longest in the
   store (full dependency tree). Don't batch it with other deploys.
2. **Interactive first run:**
   `docker compose run --rm directory --run-cli`
   Create the bot's profile when prompted. In the CLI, add your own
   SMP server (the address from the simplex stack) so the bot's
   queues live on your server, and note two things from this
   session: the bot's **contact address** (that's what users add)
   and **your own profile's ID** (needed for superusers).
   VERIFY: exact CLI commands for servers/address against upstream's
   `apps/simplex-directory-service/README.md` for the pinned tag —
   the flow above follows it, the keystrokes may differ slightly.
3. **Set yourself as superuser:** put `DIRECTORY_SUPERUSERS=<your
   id>:<your name>` in the stack's `.env`, then start the stack
   normally (`docker compose up -d`). Superusers approve listings.
4. **Registering groups:** a group owner connects to the bot, sends
   `/help`, and invites the bot into the group as `admin` — same
   flow as the official directory.

Yours vs the official directory: independent services, independent
lists. Nothing about running yours changes the official one; a
group can be in both, and your client can hold both bots as
contacts. Your registry's content rules are yours — that's the
point of self-hosting it.

Data: everything lives in `./data` (profile, registry database,
and the public `web/` listing the bot maintains). Back it up —
the profile IS the bot's identity; lose it and the registry's
address changes.
