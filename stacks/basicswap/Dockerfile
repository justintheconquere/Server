# BasicSwap — Particl's atomic-swap DEX: BTC<->XMR (and more pairs)
# with no custodian, no account, and no protocol fee. Everything the
# web UI does goes through a local JSON API on :12700 — that API is
# the agent connection point (Hermes/Goose/n8n can place bids, post
# offers, and run Smart Buy's plan-then-place flow over plain HTTP).
#
# WARNING, from BasicSwap's own docs: anyone who can reach the API
# can spend the coins in its wallets. Set the UI password (see the
# stack README), keep the port tailnet-only, and start with tiny
# amounts. BasicSwap is beta software — its July 2026 releases fixed
# refund-path bugs after a reported fund loss. Current version only.
#
# No official container image exists, so this builds from the pinned
# upstream release. VERIFY at first build: the pip install from the
# release tarball provides the basicswap-prepare / basicswap-run
# console scripts.
FROM python:3.12-slim-bookworm
ARG BASICSWAP_VERSION=v0.19.1
RUN apt-get update \
 && apt-get install -y --no-install-recommends git build-essential \
 && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir \
    https://github.com/basicswap/basicswap/archive/refs/tags/${BASICSWAP_VERSION}.tar.gz
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
VOLUME /data
EXPOSE 12700
ENTRYPOINT ["/entrypoint.sh"]
CMD ["basicswap-run", "--datadir=/data"]
