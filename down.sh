#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/.env"

COMPOSE_FILES="-f docker-compose.yml"
if [ "${PROXY_ENABLED:-false}" = "true" ]; then
  COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.proxy.yml"
fi

docker compose $COMPOSE_FILES down "$@"
