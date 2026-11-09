# Toolbox — raw scripts + cron

A small always-on container for the jobs that are just scripts:
health checks, cleanup, stack babysitting, pulling reports. It has
bash, python3, cron, curl, jq, git, rsync, and the Docker CLI +
Compose plugin. Business workflows with approvals belong in n8n;
this is the machine-level toolbox.

## Add a job

1. Put the script in `scripts/` and `chmod +x` it.
2. Add a line to `crontab` (an example is in the file).
3. `docker compose restart toolbox` — the crontab loads at start.

Job output lands in the container log: `docker logs toolbox`.
Ad-hoc work: `docker exec -it toolbox bash`.

## Rules

- **The Docker socket is mounted on purpose** so scripts can manage
  the stacks. That is root-equivalent on the host. Nothing untrusted
  goes in `scripts/` — ever.
- **No ports are published.** If a job needs to reach a service, use
  its stack name on a shared network or `host.docker.internal` for
  host services (Ollama :11434, monerod restricted RPC :18089).
- Times in the crontab are **America/New_York** (TZ in the compose).
- Scratch space and job output files: `./data` (mounted at `/data`),
  which is in the Backrest scope. Scripts themselves live in git.
