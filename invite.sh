#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/.env"

RESULTS=$(docker compose exec -T db psql -U remote -d remote -t -A -F '|' -c "
  SELECT i.token, i.email, i.role, o.name, u.username
  FROM organization_invitations i
  JOIN organizations o ON o.id = i.organization_id
  LEFT JOIN users u ON u.id = i.invited_by_user_id
  WHERE i.status = 'pending' AND i.expires_at > now();
")

if [ -z "$RESULTS" ]; then
  echo "No pending invitations."
  exit 0
fi

PORT="${HTTPS_PORT:-443}"
if [ "$PORT" = "443" ]; then
  BASE="https://${LAN_IP}"
else
  BASE="https://${LAN_IP}:${PORT}"
fi

echo "Pending invitations:"
echo ""
while IFS='|' read -r token email role org invited_by; do
  echo "  To:      $email ($role)"
  echo "  Org:     $org"
  [ -n "$invited_by" ] && echo "  From:    $invited_by"
  echo "  Link:    ${BASE}/invitations/${token}/accept"
  echo ""
done <<< "$RESULTS"
