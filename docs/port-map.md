# Port map — ufo

Every host port the stacks publish. Exposure classes: **tailnet/LAN** =
reachable on the home network and Tailscale only (nothing is port-forwarded
from the router except where marked public); **public** = reachable from the
internet by design.

| Host port | Service | Stack | Exposure |
|---|---|---|---|
| 3000 | Twenty CRM | twenty | tailnet/LAN |
| 3002 | Twenty customer portal | twenty-portal | tailnet/LAN (public via tunnel later, after vetting) |
| 3003 | Bitcart (store/admin) | bitcart | tailnet/LAN |
| 3004 | Chrome (browser UI) | chrome | tailnet/LAN |
| 3005 | Homepage dashboard | dashboard | tailnet/LAN |
| 3006 | Monero GUI wallet (Webtop desktop) | monerod | **tailnet only** — holds keys |
| 3552 | Arcane | arcane | tailnet/LAN |
| 5223 | SimpleX SMP | simplex | public (by design) |
| 443 | SimpleX XFTP | simplex | public (by design) |
| 6167 | Conduit (Matrix) | conduit | tailnet/LAN (federation via tunnel/domain later) |
| 7777 | strfry (Nostr relay) | strfry | tailnet/LAN (public wss via tunnel) |
| 8010 | Gluetun status page | gluetun | tailnet/LAN |
| 8012 | Goose (help page; agent API unpublished) | goose | tailnet/LAN |
| 8013 | Haveno status page | haveno | tailnet/LAN |
| 8014 | Haveno seed node status page | haveno-seednode | tailnet/LAN |
| 8015 | Arch + Phosh (noVNC) | arch-phosh | tailnet/LAN |
| 5225 | SimpleX help page | simplex | tailnet/LAN |
| 7681 | Web terminal (ttyd) | ttyd | **tailnet only** — root shell |
| 8040 | Poznote web UI | poznote | tailnet/LAN |
| 8045 | Poznote MCP server | poznote | tailnet/LAN, token-auth |
| 8888 | Gluetun HTTP proxy | gluetun | tailnet/LAN |
| 9898 | Backrest | backrest | tailnet/LAN |
| 11434 | Ollama API | ollama | tailnet/LAN |
| 18080 | monerod P2P | monerod | public (by design) |
| 18081 | monerod RPC (login required) | monerod | LAN/tailnet |
| 18083 | monerod ZMQ pub | monerod | LAN/tailnet (P2Pool) |
| 18089 | monerod restricted RPC | monerod | LAN/tailnet |
| 23000 | BTCPay Server | btcpay | tailnet/LAN (public face = pay.voodoobazaar.com via tunnel) |
| 9090 | Cockpit (host package, not Docker) | — | tailnet/LAN |

Web UI on 8040; the MCP
server on 8045 is the integration point Muse uses (Bearer token).
