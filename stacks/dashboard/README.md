# Dashboard (Homepage) — how to edit

Everything is YAML in `config/`:

- **Tiles:** `config/services.yaml` — one block per app (name, icon, href,
  description, and `server`/`container` for live status). Group headings
  there must match the group names in `config/settings.yaml`'s layout.
- **Look:** `config/settings.yaml` — title, theme, group layout.
- **Top widgets:** `config/widgets.yaml` — host CPU/RAM/disk + clock.
- **Docker link:** `config/docker.yaml` — points at the host socket
  (mounted read-only by the compose file). Also enables label discovery:
  every stack in this repo carries `homepage.*` labels, so its tiles can
  also appear automatically.

**Icons:** in `services.yaml`, `icon: ollama` (bare slug) loads from the
dashboard-icons set over CDN; `icon: twenty.svg` loads a local file from
this stack's `icons/` folder (mounted into the app at `/app/public/icons`).
The local files are generated monograms for apps with no dashboard-icons
entry — replace any of them with a real logo file (same filename) whenever.

**After editing:** restart the stack (`docker compose restart` in this
folder, or from Arcane). If you open the dashboard by a new hostname or
address and get a "blocked host" error, add it to `HOMEPAGE_ALLOWED_HOSTS`
in `docker-compose.yml` first.
