# ufo — Server Configuration & Deployment

Configuration and documentation for **ufo**, a self-hosted server rebuilt
from umbrelOS to **Ubuntu Server + Docker** (fresh installs, no data migrated
from the old system). This repo is the box's source of truth: every service
runs from a Compose stack kept here, so the machine can be rebuilt from this
repo plus the secrets stored on the box itself.

- **The plan** (decisions, rationale, open questions): [`PLAN.md`](PLAN.md)
- **This README**: manual deployment instructions and operating documentation.

## Hardware

| | |
|---|---|
| Board | MSI MS-7D37 |
| CPU | Intel i9-14900KF (no iGPU) |
| RAM | 64 GB DDR5 |
| Disk | 2 TB NVMe |
| GPU | NVIDIA RTX 5090 (Blackwell, sm_120) |
| LAN | 192.168.4.216 |
| Tailnet | 100.122.244.66 (Tailscale IP carries over; node rejoins on rebuild) |

## Rules of the house

- **Secrets live on the box only.** Stacks carry `.env.example` templates in
  this repo; real `.env` files are created on the box and never committed.
  `.env` is gitignored from day one.
- **Images are pinned** by tag (digest where practical). No `:latest` unless
  upstream forces it.
- **Exposure classes, never mixed:** (A) tailnet/LAN only — Arcane, Twenty,
  dashboards, AI APIs; (B) own-auth public via Cloudflare Tunnel — BTCPay,
  later the customer portal; (C) non-HTTP public — SimpleX ports, monerod
  P2P, Tor onions. Monero RPC never goes through Cloudflare.
- One service, one folder under `stacks/`, one Compose project per folder.

## Repository layout

```
PLAN.md              # the rebuild plan and decision record
README.md            # this file — deployment + operations
stacks/
  arcane/            # Docker management UI
  poznote/           # notes app + MCP server
  cloudflared/       # Cloudflare Tunnel connector
  monerod/           # Monero node (+ tor sidecar)
  ollama/            # LLM runtime (GPU)
  twenty/            # Twenty CRM
  btcpay/            # BTCPay Server, Monero-only
  bitcart/           # Bitcart (side-by-side test)
  backrest/          # backups to external USB
  dashboard/         # front-page dashboard (Homarr or Homepage — see PLAN.md)
  …                  # chrome, gluetun, simplex, conduit, strfry, goose,
                     # haveno, haveno-seednode, arch-phosh
docs/                # port map, address book, decisions log
```

Each stack folder holds `docker-compose.yml`, `.env.example`, and a short
`README.md` with anything stack-specific.

---

# Manual deployment

Work through the stages in order. Each stage ends with a **gate** — do not
continue past a failed gate; the notes under it say what the failure means.

## Stage 0 — Before the wipe (optional, ~1 minute)

Only if the current Tor onion address should survive
(`fo4zlgpyfpxshixllapt6jxcdz76eh2twdqlmmddk67gefzamlt6fmyd.onion`, used by
saved wallet remote-node configs): stop the Monero app in umbrelOS, then copy
these two folders off the box (USB stick or another machine):

```
~/umbrel/tor/data/app-monero-rpc/
~/umbrel/tor/data/app-monero-p2p/
```

Skip this and the address is gone permanently. Nothing else is carried over.

## Stage 1 — Ubuntu Server

Install **Ubuntu Server 26.04 LTS** (kernel 7.0, supported to May 2031;
fallback: 24.04 LTS with the HWE kernel).

- Hostname: `ufo`
- Install OpenSSH server during setup; do **not** install Docker as a snap.
- Keep the LAN address **192.168.4.216** (DHCP reservation on the router or a
  static address in the installer).
- Do not enable suspend/sleep (RTX 50-series resume hangs are reported on
  kernel 7.0).
- After first boot:

```
sudo apt update && sudo apt upgrade -y
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

**Gate 1:** the box boots clean, answers on 192.168.4.216, and SSH on the LAN
works.

## Stage 2 — NVIDIA driver, Docker, container toolkit

The RTX 5090 is Blackwell: NVIDIA **requires the open kernel modules** for
this card; the proprietary modules are unsupported. Ubuntu's automatic driver
picker does not always choose correctly — install the `-open` package
explicitly. (580 is Ubuntu's long-term branch and pairs with CUDA 13
containers.)

```
sudo apt install -y nvidia-driver-580-open
sudo reboot
nvidia-smi
```

`nvidia-smi` must list the RTX 5090. If the card is missing or the driver
fails to load, check the BIOS: **Above-4G decoding** and **ReBAR** enabled.

Docker CE from Docker's own apt repository (follow
<https://docs.docker.com/engine/install/ubuntu/> — repository setup, then):

```
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

NVIDIA container toolkit (follow
<https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html>
— add NVIDIA's `libnvidia-container` apt repo and key, then):

```
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
docker run --rm --gpus all nvidia/cuda:13.0-base-ubuntu24.04 nvidia-smi
```

**Gate 2:** the test container's `nvidia-smi` shows the 5090. *This is the
gate that matters.* On the old system an outdated driver made every AI app
silently fall back to CPU — nothing AI-related gets installed until this
passes.

## Stage 3 — Tailscale and SSH

```
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
sudo tailscale set --ssh
```

- Reuse the machine name `ufo`; remove the stale umbrelOS-era node from the
  Tailscale admin console if a duplicate appears.
- Tailscale SSH authenticates with tailnet identity — no key files. It needs
  an `ssh` section in the tailnet policy file (Tailscale admin console →
  Access controls); use `action: "check"` for sensitive users.
- Plain OpenSSH stays available on the LAN/tailnet as a fallback; do not
  forward port 22 from the router.

**Gate 3:** `ssh ufo` (MagicDNS name) connects from another tailnet device.
Note for apps that hard-wire their own address (Twenty): always use the
MagicDNS name or the 100.x address — never a `.local` name; phones cannot
resolve those (this exact issue broke Twenty on the old system).

## Stage 4 — Clone this repo and create the real env files

```
sudo apt install -y git
git clone https://github.com/justintheconquere/Server.git ~/server-config
cd ~/server-config
```

Create the shared network once — stacks that talk to each other (BTCPay →
monerod, portal → Twenty, Bitcart/Haveno → monerod) join it and use plain
service names (`monerod:18081`, `twenty:3000`):

```
docker network create ufo-net
```

For each stack being deployed, create its real `.env` from the template and
fill in generated secrets **on the box**:

```
cp stacks/<name>/.env.example stacks/<name>/.env
nano stacks/<name>/.env
```

Generate a random secret wherever one is needed:

```
openssl rand -hex 32
```

## Stage 5 — Arcane (container management)

```
cd ~/server-config/stacks/arcane
docker compose up -d
```

- UI: `http://ufo:3552` (tailnet/LAN only). Default login `arcane` /
  `arcane-admin` — change it at first sign-in.
- Arcane mounts the host Docker socket and manages the stacks in this repo
  (its projects directory points at `~/server-config/stacks`). Deploy the
  remaining stacks from Arcane, or with `docker compose up -d` in each
  folder — both operate on the same projects.

## Stage 6 — Poznote

```
cd ~/server-config/stacks/poznote && docker compose up -d
```

Notes app (web UI 8040) + its MCP server (8045, tailnet/LAN only, token-authenticated). Goes up early: project
plans live here. If the note database starts empty, the Voodoo Bazaar plan
notes are recreated from their off-box backups.

## Stage 7 — cloudflared

The tunnel itself lives in Cloudflare and survives the rebuild; only the
connector is reinstalled. Run it from the stack folder with the tunnel token
stored in that stack's `.env` (box only):

```
cd ~/server-config/stacks/cloudflared && docker compose up -d
```

Routes only the public, own-auth services: BTCPay at
**pay.voodoobazaar.com** today; the customer portal later. Nothing else goes
in the tunnel.

## Stage 8 — monerod

```
cd ~/server-config/stacks/monerod && docker compose up -d
```

- Same image the Umbrel app used (`ghcr.io/sethforprivacy/simple-monerod`).
- **Pruned node** by default (`prune-blockchain=1`, ~105 GiB). Full node
  (~265 GiB) only if an archival copy is ever wanted.
- RPC login is **on**, with the credential generated into the stack `.env`:
  monerod runs with `--rpc-login` set from it. (On umbrelOS the app generated
  credentials but never actually enforced them on the daemon — here it is
  configured deliberately.)
- ZMQ pub on `tcp://0.0.0.0:18083` (for P2Pool). RPC 18081 reachable on
  LAN/tailnet only; restricted RPC on 18089.
- If Stage 0 was done, the saved `app-monero-rpc` / `app-monero-p2p` folders
  go into the tor sidecar's data directory (owned by the tor user, `0700`)
  and the old `.onion` address comes back unchanged. Otherwise a fresh onion
  is generated — update wallet remote-node configs to the new address.

Check sync progress:

```
curl -s -u monero:<password> http://127.0.0.1:18081/get_info
```

**Gate 4:** `get_info` answers with the RPC login, block height is climbing.

## Stage 9 — Ollama (GPU)

```
cd ~/server-config/stacks/ollama && docker compose up -d
ollama pull gpt-oss:120b
ollama pull gpt-oss:20b
ollama pull llama3.1:70b
ollama pull qwen3.5:35b
ollama pull qwen3.8
```

**Gate 5:** with a model loaded, `ollama ps` shows **100% GPU**. A warm
qwen3.8 run should be in the ~140 tok/s class (the verified figure from the
old system). CPU in the `ollama ps` output = driver problem back at Gate 2,
not an Ollama problem.

## Stage 10 — Twenty CRM

```
cd ~/server-config/stacks/twenty && docker compose up -d
curl --fail http://ufo:3000/healthz
```

- Official stack: server + worker + PostgreSQL 16 + Redis. **Both** server
  and worker must run — without the worker, background jobs silently fail.
- `SERVER_URL` in the stack `.env` uses the MagicDNS/100.x address (never
  `.local`). Tailscale-only — no tunnel route, no port forward.
- **First account to sign up becomes the workspace admin** — create it right
  after the health check passes.
- The AssureBay data model (Customers with Customer ID, Policies, Prospects,
  Partners) is built afterwards as Twenty custom objects from the data
  dictionary in the `assurebay-crm` repo.

## Stage 11 — Everything else

Deploy from their stack folders (or Arcane) as wanted:

- **BTCPay (Monero-only)** — after monerod is fully synced. BTCPay +
  PostgreSQL + monero-wallet-rpc only (no bitcoind, no NBXplorer);
  `BTCPAY_HOST=pay.voodoobazaar.com` via the Stage 7 tunnel; daemon URI
  points at the Stage 8 node with its RPC login. Wallet-RPC port 18082 is
  internal to the stack's network, published nowhere.
- **Backrest** — external 1 TB USB drive, ext4, label `ufo-backup`. A
  pre-backup hook checks the drive is actually mounted and aborts if not.
  Scope: stack configs, app databases, identity data (SimpleX, strfry).
  Models and the Monero chain are excluded — both are re-creatable.
  The restic repo password goes in a password manager: lose it, lose the
  backups.
- **Dashboard (Homepage)** — YAML-configured front page, config files in
  `stacks/dashboard/config/` in this repo; deploy the stack
  (`stacks/dashboard`), then it answers at `ufo:3005`, tailnet/LAN only.
  Apps appear via the entries in `services.yaml` (one per app, each with its
  icon) plus Docker label auto-discovery.
- **Bitcart, Chrome, Gluetun, SimpleX, Conduit, strfry, Goose, Haveno,
  Haveno seednode, Arch + Phosh** — per their stack folders. SimpleX and
  strfry identity keys are part of the Backrest scope from first start.

---

# Operations

## Address book

| Service | Address | Exposure |
|---|---|---|
| Arcane | `ufo:3552` | tailnet/LAN |
| Dashboard (Homepage) | `ufo:3005` | tailnet/LAN |
| Twenty | `ufo:3000` | tailnet only |
| Poznote | `ufo:8040` | tailnet/LAN |
| Poznote MCP | `ufo:8045` | tailnet/LAN, token-auth |
| Ollama API | `ufo:11434` | tailnet/LAN |
| monerod RPC | `ufo:18081` (login required) | LAN/tailnet |
| monerod restricted RPC | `ufo:18089` | LAN/tailnet |
| monerod ZMQ | `ufo:18083` | local networks (P2Pool) |
| monerod P2P | `18080` | public |
| monerod RPC over Tor | `fo4z…fmyd.onion:18081` (if keys saved) | Tor |
| BTCPay | `pay.voodoobazaar.com` | public via tunnel |
| Cockpit (optional) | `ufo:9090` | tailnet/LAN |

## Updating a stack

```
cd ~/server-config/stacks/<name>
docker compose pull
docker compose up -d
docker compose logs -f --tail=50
```

Then commit any compose change back to this repo — the repo must always
describe what's actually running.

## Updating the host

`unattended-upgrades` covers security patches. For a manual pass:

```
sudo apt update && sudo apt upgrade -y
nvidia-smi   # confirm the 5090 still loads after any driver/kernel change
```

After any NVIDIA driver change, re-run the Gate 2 container check and the
Gate 5 `ollama ps` check before assuming the AI stack is healthy.

## Troubleshooting quick hits

- **AI app slow / running on CPU** → driver. `nvidia-smi` on the host, then
  inside the container. Never debug the app first.
- **Twenty loads for a second then dies** → its `SERVER_URL` doesn't match
  the address you're opening. Twenty hard-wires it; they must match exactly.
- **A service answers on LAN but not from the phone** → you're using a
  `.local` name. Use the MagicDNS name or the 100.x address.
- **monerod won't open its database** → data-dir ownership. The daemon runs
  as UID/GID 1000; the data directory must be writable by it.
