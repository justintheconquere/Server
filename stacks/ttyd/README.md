# Web terminal (ttyd)

A real terminal on ufo, in a browser tab: **http://ufo:7681**, from the
tailnet or home LAN only. Log in with `TTYD_USER` / `TTYD_PASSWORD` from
this stack's `.env`.

How it works: the container is privileged and shares the host's PID
namespace; ttyd serves an `nsenter` session that steps into the host's
namespaces and opens a login shell. You are root-equivalent on the host
— `docker`, `systemctl`, everything works, exactly like sitting at the
machine. Closing the tab or typing `exit` ends the session.

Rules that come with that power:

- **Tailnet-only, forever.** Never port-forward 7681, never add it to
  the Cloudflare tunnel, never expose it on any other interface. The
  basic-auth password is the only door — make it strong and unique
  (compose won't start without one).
- **Don't share ttyd's logs.** Its startup log prints the credential
  base64-encoded. Anyone with the log effectively has the password.
- If you ever don't need it for a while, just stop the stack
  (`docker compose stop` here, or from Arcane) — a terminal that isn't
  running can't be attacked.

Alternatives already in the plan, for completeness: Tailscale SSH
(README Stage 3) from any SSH app, and Cockpit (host package, :9090)
which also includes a terminal. ttyd is the lightest of the three and
the only one that needs nothing installed on the host.
