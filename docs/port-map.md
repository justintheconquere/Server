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
| 3007 | Gitea web UI | gitea | tailnet/LAN |
| 2222 | Gitea git SSH | gitea | tailnet/LAN |
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
| 11434 | Ollama API | native host install OR ollama stack — run one | tailnet/LAN |
| 2283 | Immich | immich | tailnet/LAN |
| 3008 | Open WebUI | open-webui | tailnet/LAN |
| 3009 | Uptime Kuma | uptime-kuma | tailnet/LAN |
| 3010 | Vaultwarden | vaultwarden | tailnet/LAN |
| 3011 | SearXNG | searxng | tailnet/LAN |
| 3012 | Paperless-ngx | paperless | tailnet/LAN |
| 3013 | Stirling-PDF | stirling-pdf | tailnet/LAN |
| 3014 | changedetection.io | changedetection | tailnet/LAN |
| 3015 | Cup | cup | tailnet/LAN |
| 3016 | RomM | romm | tailnet/LAN |
| 8096 | Jellyfin | jellyfin | tailnet/LAN |
| 8188 | ComfyUI | comfyui | tailnet/LAN |
| 5678 | n8n (workflow automation) | n8n | tailnet/LAN |
| 8642 | Hermes gateway API (key required) | hermes | tailnet/LAN |
| 9119 | Hermes dashboard (basic auth) | hermes | tailnet/LAN |
| 18080 | monerod P2P | monerod | public (by design) |
| 18081 | monerod RPC (login required) | monerod | LAN/tailnet |
| 18083 | monerod ZMQ pub | monerod | LAN/tailnet (P2Pool) |
| 18089 | monerod restricted RPC | monerod | LAN/tailnet |
| 23000 | BTCPay Server | btcpay | tailnet/LAN (public face = pay.voodoobazaar.com via tunnel) |
| 9090 | Cockpit (host package, not Docker) | — | tailnet/LAN |
| 3017 | Dify (nginx front door) | dify | tailnet/LAN |
| 3018 | LocalAI | localai | tailnet/LAN |
| 9000 | Medusa (Store/Admin API + admin UI) | medusa | tailnet/LAN |
| 3100 | Paperclip | paperclip | tailnet/LAN |
| 8080 | qBittorrent WebUI | torrents (published by gluetun) | tailnet/LAN |
| 6881 | BitTorrent peers (TCP + UDP) | torrents (published by gluetun) | egress via VPN |
| 9696 | Prowlarr | torrents | tailnet/LAN |
| 12700 | BasicSwap (UI + JSON API) | basicswap | tailnet/LAN |
| 8016 | SimpleX Directory status page (the service is a chat bot) | simplex-directory | tailnet/LAN |
| — | Toolbox (scripts + cron) | toolbox | no published ports |

Web UI on 8040; the MCP
server on 8045 is the integration point Muse uses (Bearer token).
