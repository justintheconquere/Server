#!/bin/sh
# Runs the directory bot. DIRECTORY_SUPERUSERS (format: id:name,
# comma-separated) is only known after the first interactive run —
# see README.md. Extra args are passed through, e.g. for the
# interactive first run: docker compose run --rm directory --run-cli
set -e
ARGS="--database /data/db --web-folder /data/web --service-name ${DIRECTORY_NAME:-ufo Directory}"
if [ -n "$DIRECTORY_SUPERUSERS" ]; then
  ARGS="$ARGS --super-users $DIRECTORY_SUPERUSERS"
fi
exec simplex-directory-service $ARGS "$@"
