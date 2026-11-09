#!/bin/bash
# Load the mounted crontab (if any) and run cron in the foreground.
# Restart the container after editing the crontab — it loads at start.
set -e
if [ -f /config/crontab ]; then
  crontab /config/crontab
  echo "toolbox: loaded crontab from /config/crontab"
else
  echo "toolbox: no /config/crontab — cron idle; container is up for docker exec"
fi
exec cron -f
