# Haveno — status: REAL BUILD, still experimental. Do not fund big.

State of this stack (rebuilt 2026-11-09):

- Upstream Haveno publishes **no official Docker image**, so the
  stack's `Dockerfile` builds the daemon from upstream source at the
  pinned release (v1.9.0, JDK 21, Gradle `installDist`). The first
  build is long and RAM-hungry; the Dockerfile names the two VERIFY
  items to confirm from the build log (Gradle output paths, Tor).
- **Agent access is the point of this stack.** The daemon serves a
  gRPC API on port 9998, exposed only inside `ufo-net` — Hermes,
  Goose, or n8n reach it at `haveno-daemon:9998` with the API password
  from this stack's `.env`. TypeScript clients (haveno-ts) speak
  gRPC-Web and additionally need an Envoy proxy in front — Haveno's
  repo ships the config (`make envoy-mainnet`); add it as a sidecar
  if a TS client ever needs it. Raw gRPC clients need nothing extra.
  The daemon can also publish its API as a Tor onion
  (`--apiHiddenService=true`) — off by default; anyone holding the
  onion address AND the password controls the wallet.
- The API password = full wallet control for anyone who reaches the
  port. `ufo-net` only, never published, never through the tunnel.
- Network: the compose joins `XMR_MAINNET`. Which network a build
  actually joins is defined by the build's baked-in seed nodes —
  upstream's own mainnet presence is young and the established live
  network (RetoSwap) ships its own build. Confirm the offer board
  is real before funding anything; stagenet is one flag change
  (`--baseCurrencyNetwork=XMR_STAGENET`, test password conventions
  in Haveno's docs) and is the right place to wire agents first.
- Wallet/seed live in `./data/haveno` — funds-critical, encrypted
  backup before any update, seed written down offline.
- Check current Haveno security advisories before real funds
  (exploits were reported in 2026). Test amounts only, first.
