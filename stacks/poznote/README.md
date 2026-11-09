# Poznote — first-boot notes

- Web UI: `http://ufo:8040` — create the admin account on first visit
  (first user becomes the account Poznote's MCP acts as, user id 1).
- MCP endpoint: `http://<tailnet-ip>:8045/mcp` (Bearer token from `.env`).
  After deploy, tell Muse the token once in chat — Muse's Poznote
  connector doc gets updated to the new endpoint (the old umbrelOS one
  was :8340 with a different token; both change here).
- All notes live in `./data` (SQLite). Backrest covers the stacks tree;
  also export from the UI occasionally — the Voodoo Bazaar plan and every
  other project plan live in here.
- Updates: upstream's rule — follow the repo's update instructions
  (github.com/timothepoznanski/poznote#update-application) rather than a
  blind `docker compose pull`.
