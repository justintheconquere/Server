# monerod stack — node + GUI wallet

Two things live here: the shared Monero node (`monerod`, with its Tor
sidecar) and the official **Monero GUI wallet** in a browser desktop
(`wallet-gui`, built from `wallet/Dockerfile` — official GUI v0.18.5.4
release, SHA256-verified at build time, on a LinuxServer Webtop base).

## Opening the wallet

- Address: **http://ufo:3006** — from a device on the **tailnet** (or the
  home LAN). Log in with the `WALLET_GUI_USER` / `WALLET_GUI_PASSWORD`
  from this stack's `.env`.
- **Tailnet-only, permanently.** This desktop holds wallet keys. Never
  port-forward it, never put it behind the Cloudflare tunnel, never
  publish it on any other interface.
- The wallet autostarts with the desktop; it's also in the XFCE app menu
  as "Monero GUI Wallet".

## First-run setup (Justin's step — it creates the wallet and its seed)

1. In the wallet wizard choose **Advanced mode** (Simple mode hides the
   node settings and would use someone else's node).
2. Create a new wallet (or restore from seed). **Write the seed down
   offline** — the wallet files live in `data/wallet/Monero/wallets/`
   on the box, and the seed is the only recovery if that data is lost.
3. Point it at this stack's own node: **Settings → Node → Remote node**:
   - Address: `monerod`, Port: `18081`
   - Daemon username / password: the `MONERO_RPC_USER` / `MONERO_RPC_PASS`
     values from this stack's `.env`
   - Mark it trusted if the GUI asks (it is your own node, on the same
     box, reached over the internal Docker network).
4. Wait for the node to be synced (see the main README, Stage 8) and the
   wallet to finish its initial refresh before trusting balances.

Notes:

- Hardware wallets (Ledger/Trezor) can't be used from this container —
  no USB passthrough. This wallet is for hot-wallet use; keep real
  reserves in cold storage as usual.
- Wallet data is covered by Backrest only if `data/wallet` is in its
  scope; the seed phrase, kept offline, is the backup that matters.
- Updating the wallet version = editing the two ARGs in
  `wallet/Dockerfile` (version + SHA256 from the release's signed
  hashes.txt) and rebuilding from Arcane or the compose folder.
