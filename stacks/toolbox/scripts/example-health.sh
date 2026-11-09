#!/bin/bash
# Example toolbox job: is the Monero node answering, and how's the disk?
# Copy this as a starting point for real jobs. (chmod +x your scripts.)
set -u
echo "[$(date -Is)] health check"
# 18089 is monerod's restricted RPC — get_info answers without the login.
curl -s http://host.docker.internal:18089/get_info \
  | jq -r '"monerod height: \(.result.height // "NO ANSWER")"'
df -h / | tail -1
docker ps --format '{{.Names}}: {{.Status}}' | sort
