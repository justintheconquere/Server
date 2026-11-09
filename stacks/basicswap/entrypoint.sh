#!/bin/sh
# First run: prepare the data dir (downloads the coin tools for the
# coins in $COINS — Monero's are a few hundred MB, so it takes a
# while). Later runs skip straight to the daemon.
set -e
if [ ! -f /data/basicswap.json ]; then
  echo "[basicswap] first run: preparing data dir for coins: ${COINS:-xmr}"
  basicswap-prepare --datadir=/data --coins="${COINS:-xmr}"
fi
exec "$@"
