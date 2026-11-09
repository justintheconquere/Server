# ttyd — share a terminal over the web. The official static binary,
# pinned (1.7.7, current as of 2026-11), on a slim Debian base that
# provides nsenter (util-linux) and bash — the two things the host-shell
# pattern in docker-compose.yml needs. Bump = change TTYD_VERSION.
FROM debian:13-slim

ARG TTYD_VERSION=1.7.7

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates util-linux \
    && curl -fsSL -o /usr/local/bin/ttyd \
      "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" \
    && chmod 0755 /usr/local/bin/ttyd \
    && rm -rf /var/lib/apt/lists/*
