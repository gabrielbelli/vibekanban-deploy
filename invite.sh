#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/.env"

TOKENS=$(docker compose exec -T db psql -U remote -d remote -t -A \
  -c "SELECT token FROM organization_invitations WHERE status = 'pending';")

if [ -z "$TOKENS" ]; then
  echo "No pending invitations."
  exit 0
fi

PORT="${HTTPS_PORT:-443}"
if [ "$PORT" = "443" ]; then
  BASE="https://${LAN_IP}"
else
  BASE="https://${LAN_IP}:${PORT}"
fi

echo "Pending invite links:"
while IFS= read -r token; do
  echo "  ${BASE}/invitations/${token}/accept"
done <<< "$TOKENS"
