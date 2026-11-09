# Toolbox — raw scripts + cron runner for ufo.
# Debian slim (same base as the ttyd stack) with the tools a script
# usually reaches for, plus the Docker CLI + Compose plugin from
# Docker's own apt repo (the same method the host install uses,
# README Stage 2) so scripts can inspect and manage the stacks.
FROM debian:13-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash cron curl jq git python3 rsync openssh-client \
      ca-certificates tzdata \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
