# SimpleX Directory Service — the group-registry bot from the
# simplex-chat project: users connect to it as a chat contact, send
# /help, and register or search groups. This is YOUR registry, on
# your own server — it runs ALONGSIDE the official SimpleX directory,
# not instead of it; the same app can hold both as contacts, and
# groups can be listed in either or both.
#
# No official container image exists, so this builds the binary from
# the pinned simplex-chat release with cabal. It is the LONGEST
# build in the store by far (a full Haskell dependency tree — build
# it alone, expect the better part of an hour and several GB of RAM).
# VERIFY at first build: the GHC version below against the repo's
# CI for the pinned tag, and the built binary's path.
FROM ubuntu:24.04 AS build
ARG SIMPLEX_VERSION=v7.1.2
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git curl build-essential pkg-config \
      libgmp-dev zlib1g-dev libsqlite3-dev libssl-dev \
 && rm -rf /var/lib/apt/lists/*
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
    BOOTSTRAP_HASKELL_NONINTERACTIVE=1 sh
ENV PATH="/root/.ghcup/bin:${PATH}"
RUN ghcup install ghc 9.6.6 && ghcup set ghc 9.6.6 \
 && ghcup install cabal 3.10.3.0 && ghcup set cabal 3.10.3.0
WORKDIR /src
RUN git clone --depth 1 --branch ${SIMPLEX_VERSION} https://github.com/simplex-chat/simplex-chat.git .
RUN cabal update && cabal build simplex-directory-service \
 && find dist-newstyle -name simplex-directory-service -type f -executable \
      | head -1 | xargs -I{} cp {} /simplex-directory-service

FROM debian:13-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates libgmp10 libsqlite3-0 libssl3 \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /simplex-directory-service /usr/local/bin/simplex-directory-service
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
VOLUME /data
ENTRYPOINT ["/entrypoint.sh"]
