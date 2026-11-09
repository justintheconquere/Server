# Haveno — status: SCAFFOLDING, do not fund

Honest state of this stack (checked 2026-11-08, re-check at deploy):

- Upstream Haveno publishes **no official Docker image**. The one published
  daemon image (`havenodex/haveno-daemon`) is **ARM64-only** — it will not
  run natively on this amd64 box. The realistic path is a self-built amd64
  image from `haveno-dex/haveno` (or the RetoSwap fork), pinned here by
  digest once built.
- The flags in `docker-compose.yml` follow Haveno's documented startup
  options (app data dir, mainnet network flag, node URI + dedicated
  username/password flags, API port/password).
- The daemon's API password = full wallet control for anyone who reaches
  port 9998. It is exposed only on the internal `ufo-net` network.
- Wallet/seed live in `./data/haveno` — funds-critical, encrypted backup
  before any update, seed written down offline.
- Check current Haveno/RetoSwap security advisories before real funds
  (exploits were reported in 2026). Test amounts only, first.
