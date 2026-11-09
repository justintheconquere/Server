# ufo Rebuild Plan — Ubuntu Server + Docker (FRESH INSTALLS)

Status: PLANNING (Justin, 2026-11-08). No execution without his explicit go.
Decision of record: umbrelOS is scrapped. ufo is wiped and rebuilt as Ubuntu
Server + Docker. **Fresh installs only — no data migration** (Justin's call:
nothing on the box he needs to keep). Every configuration is documented in a
GitHub repo so the box is reproducible: clone repo, fill in secrets, compose up.

Poznote copy: pending the Poznote token in the planning chat (token is never
stored, by design). Local file is the backup until then.

## Decisions already locked (carried over)
- Twenty stays **Tailscale-only**; the future customer portal is the separate
  public layer (Justin, 2026-11-07).
- BTCPay public domain: **pay.voodoobazaar.com**, via his existing Cloudflare
  tunnel. Monero RPC is **local-only**, never through Cloudflare; wallet-RPC
  (18082) published nowhere outside its own compose network.
- BTCPay stays primary for Voodoo Bazaar (plugin ecosystem); Bitcart bundled
  for side-by-side testing. Matrix = Conduit, not Synapse. Backup = Backrest
  (restic) to the external 1TB USB drive.
- Arcane is the container-management UI (his requirement, 2026-11-07) — on
  Ubuntu it manages the host Docker directly (no Docker-in-Docker layer).
- Secrets are generated/stored **on the box only**. The GitHub repo carries
  `.env.example` templates, never real values.

## Stage 0 — Pre-wipe (the only step that touches umbrelOS, all optional)
Nothing is migrated. Two 30-second exceptions, Justin's call each:
1. **Tor onion keys** (only if he wants to keep
   `fo4zlgpyfpxshixllapt6jxcdz76eh2twdqlmmddk67gefzamlt6fmyd.onion` for his
   saved wallet configs). Stop the Monero app, then copy two folders off the
   box (USB stick or scp):
   ```
   ~/umbrel/tor/data/app-monero-rpc/
   ~/umbrel/tor/data/app-monero-p2p/
   ```
   Skipped = the onion address changes forever. Nothing on-chain depends on it.
2. Nothing else. Twenty was likely never populated (admin signup unconfirmed);
   Ollama models re-download; the chain re-syncs (Stage 4).

**Point of no return:** starting the Ubuntu installer in Stage 1. Before that,
rollback is "do nothing — umbrelOS is untouched." After it, rollback to
umbrelOS does not exist (by design); recovery = reinstall from the GitHub repo.

## Stage 1 — Ubuntu Server install
- **Ubuntu Server 26.04 LTS** (recommended): kernel 7.0 out of the box,
  standard maintenance to May 2031, newest packaged NVIDIA branches.
  Fallback: 24.04 LTS + HWE kernel (`linux-generic-hwe-24.04`).
- Installer choices: hostname **`ufo`** (recommended — `umbrel.local` dies with
  umbrelOS; Tailscale MagicDNS name becomes the durable address, which is also
  the fix for the Nov 7 "phone can't resolve .local" Twenty failure).
  OpenSSH server installed but key-only (or left for Tailscale SSH, Stage 3).
  No snap Docker. Disable suspend (RTX 50-series s2idle resume hangs reported
  on kernel 7.0 — irrelevant on an always-on server, just don't enable it).
- Keep the LAN address **192.168.4.216** (router DHCP reservation or static).
- Enable `unattended-upgrades` for security patches.
- GATE 1: clean boot, `ip a` shows 192.168.4.216, SSH reachable on LAN.

## Stage 2 — NVIDIA driver + Docker + container toolkit (THE gate)
Blackwell rule (NVIDIA): the RTX 5090 **requires the open kernel modules**;
the proprietary modules are unsupported. Ubuntu's driver picker doesn't
always get this right — install the `-open` package explicitly:
```
sudo apt update && sudo apt install -y nvidia-driver-580-open
sudo reboot
nvidia-smi   # must show the RTX 5090, driver 580.x
```
(580 = Ubuntu's long-term branch; 595-open / 615-open also packaged on 26.04.)
BIOS check if the card misbehaves: Above-4G decoding + ReBAR enabled.

Docker CE from Docker's own apt repo (**never the snap** — snap confinement
blocks /dev/nvidia*), plus Compose v2. Then the NVIDIA container toolkit:
```
# after adding NVIDIA's libnvidia-container apt repo + key:
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
docker run --rm --gpus all nvidia/cuda:13.0-base-ubuntu24.04 nvidia-smi
```
- GATE 2: the test container sees the 5090. **Nothing AI-related proceeds
  until this passes** — this is the exact failure that cost a day on
  umbrelOS (driver 550 → silent CPU fallback).

## Stage 3 — Tailscale + SSH
- Native install from Tailscale's apt repo; `tailscale up`. The box rejoins
  the tailnet (new node key; the old `ufo` node gets removed from the admin
  console, or the hostname re-registers — same name `ufo` recommended).
- SSH — Justin's 2026-11-08 ask, two supported shapes (recommend the first):
  - **Tailscale SSH**: `sudo tailscale set --ssh`. No key files to manage;
    auth = tailnet identity. Needs an `ssh` section in the tailnet policy
    (Justin's edit in the Tailscale admin console) with `action: "check"`
    for sensitive users. Muse's existing tailnet device (`muse`, already
    approved) gets access through that same policy — this is what finally
    gives Muse real SSH into the box.
  - Plain OpenSSH with keys over the tailnet as a fallback (ufw: allow in
    on tailscale0 only; no public port 22).
- GATE 3: `ssh ufo` (MagicDNS name) works from the tailnet; Twenty's future
  SERVER_URL uses the MagicDNS name or the 100.x address, never `.local`.

## Stage 4 — Base services, in dependency order
All stacks live in the GitHub config repo, cloned on the box (e.g. `~/stacks`),
one folder per stack with `docker-compose.yml` + `.env.example`.

1. **Arcane** — `ghcr.io/getarcaneapp/manager`, port 3552, mounts
   /var/run/docker.sock, `PROJECTS_DIRECTORY` pointed at the stacks folder,
   fresh 32-byte ENCRYPTION_KEY generated on the box. Default login changed
   on first sign-in. Every stack below is then deployed/managed from Arcane.
2. **Poznote + poznote-mcp** — Muse's notes home goes back up early, before
   the projects that keep their plans there. The two Voodoo Bazaar notes are
   recreated from the local backups in `~/workspace/voodoobazaar-notes/` if
   needed. (Deployment shape on plain Docker — Poznote app + MCP sidecar —
   confirmed at build time from the official upstream compose: app
   :8040, MCP :8045 — the umbrelOS install ran an older build at :8340.)
3. **cloudflared** — his existing tunnel lives in Cloudflare; the connector
   is re-established with the tunnel token/credentials on the box only.
   Routes only the public pieces (BTCPay today; the customer portal later).
4. **monerod** — same image Umbrel used (`ghcr.io/sethforprivacy/simple-monerod`),
   plain compose. Fresh sync from block 0.
   - **Pruned (recommended)** ~105 GiB vs full ~265 GiB: serves wallet,
     BTCPay and P2Pool identically; sync finishes in a fraction of the time.
     Full only if he wants an archival node. *(Open decision.)*
   - Config set **deliberately this time** (umbrelOS left it ambiguous —
     research found nothing in the app actually passed `--rpc-login` to the
     daemon): `rpc-login` ON with a generated credential stored in the
     stack's `.env` on the box; `--zmq-pub tcp://0.0.0.0:18083` (P2Pool);
     restricted RPC on 18089 for wallet use; RPC 18081 on LAN/tailnet only.
   - Tor: a tor container in the stack; if Stage 0 keys were saved, they drop
     into its data dir and the `fo4z…` onion survives unchanged; otherwise a
     fresh onion is generated and his wallet configs get the new address.
   - GATE 4: `get_info` answers over authenticated RPC; sync height climbing;
     ZMQ port live.
   - **GUI wallet in this stack** (added 2026-11-09, Justin's request): the
     official Monero GUI (v0.18.5.4) built into a Webtop browser desktop
     (`wallet/Dockerfile` in the stack, SHA256-verified at build), served
     on :3006 **tailnet-only** (it holds keys), basic-auth via stack `.env`.
     It connects to this node only — Remote node `monerod:18081` with the
     stack RPC login; wallet creation/seed is Justin's first-run step.
     Wallet files under the stack's `data/wallet/` (gitignored, like all
     `data/`).
5. **Ollama** — official `ollama/ollama`, `--gpus=all`, models re-pulled:
   gpt-oss:120b, gpt-oss:20b, llama3.1:70b, qwen3.5:35b, qwen3.8.
   - GATE 5 (mirrors the Nov 6 proof): `ollama ps` shows the model **100% in
     VRAM**; a warm qwen3.8 run should be in the ~140 tok/s class. If it
     loads on CPU, stop — that's the driver failure mode, not an Ollama bug.
6. **LocalAI — DROPPED (Justin, 2026-11-09).** Reviewed after the build:
   his local-AI use is setup and benchmarks, not a workload, and Ollama
   covers local inference on its own. (The official CUDA 13 image made it
   a clean stack; it was removed from the repo the same day it was added.
   GPU verification lives in Gate 5 — Ollama's proof is the system's.)
7. **Twenty CRM** — official compose stack (server + worker + postgres:16 +
   redis), pinned version (v2.56.1 or current stable at build time).
   Fresh database, fresh admin signup (Justin's step, first signup = admin).
   `SERVER_URL=http://<magicdns-or-100.x>:3000`, Tailscale-only, storage
   local. The AssureBay data dictionary (14 tabs / 205 fields, in the CRM
   repo) becomes Twenty custom objects as a follow-on, not a blocker.
   - GATE 7: /healthz 200 over the tailnet address; worker processing jobs.

## Stage 5 — The rest of the app list (plain compose, from the sparkles work)
The sparkles packages' compose definitions transfer directly — the Umbrel
packaging layer (manifests, app_proxy, exports.sh) is stripped and internal
hostnames become plain compose service names:
- **BTCPay Monero-only** (btcpayserver + postgres + monero-wallet-rpc; no
  bitcoind, no NBXplorer) pointed at Stage 4 monerod; BTCPAY_HOST =
  pay.voodoobazaar.com through the tunnel; plugin set per the Voodoo plan
  (Monero, Vendor Pay, FileSeller, Dynamic Reports, Nostr + Shopstr,
  ServerMessage; Trocador phase 2). Starts once monerod is synced.
- **Twenty customer portal** (lilremark/twentycrmclientportal) — only after
  the code vetting already flagged; pilot Tailscale-only, public via tunnel
  after review. API key server-side only.
- **Backrest** → external 1TB USB (ext4, label `ufo-backup`), mountpoint
  pre-backup hook, scope: stack configs + databases + identity data;
  models and chain excluded (re-downloadable / re-syncable).
- **Bitcart** (XMR-only, side-by-side test), **Chrome** (linuxserver/chrome),
  **Gluetun**, **SimpleX** (SMP + XFTP; identity keys into Backrest scope),
  **Conduit** (server name = AssureBay domain from day one), **strfry**,
  **Goose** (headless, pointed at Ollama), **Haveno client +
  seednode**, **Arch + Phosh** container (the phone-GUI want survives as a
  plain container — nothing about it needed Umbrel).
- **XMR P2Pool rig** stays its own project (planning-only so far); on the
  new box it's p2pool + xmrig + controller against Stage 4 monerod
  (ZMQ 18083 + rpc-login are already in the config for it).
- **Cockpit** (optional, OS-level GUI: updates, logs, storage, terminal) —
  `apt install cockpit`, port 9090, tailnet-only.

## Dashboard (front page) — DECIDED 2026-11-09: Homepage
**Homepage** (gethomepage/homepage): lightweight, configured entirely in YAML
files (`services.yaml`, `widgets.yaml`, `settings.yaml`, `docker.yaml`) that
live in this repo under `stacks/dashboard/config/`. Docker label discovery is
on, so a stack can add itself to the dashboard from its own compose file.
Each app gets an icon (sourced from the dashboard-icons set where it exists,
generated otherwise) wired into `services.yaml`. Host port **3005** (Twenty
keeps 3000). Arcane remains the container manager underneath.

## GitHub config repo — `justintheconquere/Server` (decided 2026-11-08)
This plan lives in that repo as `PLAN.md`; its `README.md` carries the manual
deployment instructions and documentation. Proposed layout as stacks land:
```
README.md            # rebuild runbook: this plan, condensed
stacks/
  arcane/  poznote/  cloudflared/  monerod/  ollama/
  twenty/  btcpay/   bitcart/      backrest/ dashboard/ …
  (each: docker-compose.yml, .env.example, README notes)
docs/                # decisions, port map, address book (IPs, onions, URLs)
```
Rules: images pinned by tag (+ digest where practical); no `:latest` except
where upstream forces it; **no real secrets, ever** — a pre-commit check for
`.env` files in .gitignore from day one.

## Downtime picture
- Everything on ufo is down from the wipe until its stage completes.
  Same-day: OS, GPU stack, Arcane, Poznote, Twenty, Ollama (plus model
  download time). Long tail: **monerod sync** (pruned: plan on days, runs
  unattended; BTCPay waits for it).
- Nothing else in Justin's world depends on ufo being up minute-to-minute
  (AssureBay site/leads run on Cloudflare/Google), except Poznote access
  for Muse — hence its early slot in Stage 4.

## Open decisions for Justin
1. Dashboard: RESOLVED 2026-11-09 — **Homepage** (YAML-edited, lightweight).
2. GitHub repo: RESOLVED 2026-11-08 — `justintheconquere/Server` (plan in
   `PLAN.md`, deployment instructions + docs in `README.md`).
3. monerod: **pruned (recommended) vs full** on the fresh sync.
4. Tor onion keys: copy the two folders pre-wipe, or let the address change?
5. Ubuntu: RESOLVED 2026-11-09 — **Server latest (26.04 LTS)**. (Alternatives
   were reviewed with Justin — Debian, Proxmox, Fedora, appliance OSes,
   NixOS — Ubuntu chosen.)
6. Hostname: **`ufo` (recommended)** vs keeping `umbrel.local`.
7. SSH: **Tailscale SSH (recommended)** vs OpenSSH keys — and he's the one
   who adds the `ssh` section to the tailnet policy either way Muse is
   granted access.
8. Poznote token for the planning chat, to file this plan in Poznote.
