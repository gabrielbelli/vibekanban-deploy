#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/.env"

echo "VK_SHARED_API_BASE=${APP_URL} VK_SHARED_RELAY_API_BASE=${RELAY_URL} npx vibe-kanban"
