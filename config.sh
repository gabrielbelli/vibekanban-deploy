# ============================================================================
# Vibe Kanban — Self-Hosted Deployment Config
#
# Only the first section is required. Everything else is optional and can be
# left empty — the server will simply disable those features.
#
# After editing, delete .env and re-run ./setup.sh to apply changes.
# ============================================================================


# ========================== REQUIRED ========================================

# --- Public URLs ---
# The full URLs where the app and relay will be accessed.
# Must include the scheme (http:// or https://) and port if non-standard.
# No trailing slash.
#
# Examples:
#
#   LAN with IP (self-signed cert, built-in proxy):
#     APP_URL=https://192.168.1.177
#     RELAY_URL=https://192.168.1.177:8443
#
#   Domain with standard HTTPS (port 443, behind your own reverse proxy):
#     APP_URL=https://kanban.example.com
#     RELAY_URL=https://relay.kanban.example.com
#
#   Domain on a custom port:
#     APP_URL=https://kanban.example.com:8443
#     RELAY_URL=https://relay.kanban.example.com:9443
#
#   Local dev / plain HTTP (only works on localhost due to crypto.subtle):
#     APP_URL=http://localhost:8081
#     RELAY_URL=http://localhost:8082
#
APP_URL=https://192.168.1.177
RELAY_URL=https://192.168.1.177:8443

# --- Authentication ---
# At least one login method must be configured.
#
# Local auth (default) — works out of the box, no external services needed.
# The server checks these on every startup. Clear both to disable local auth.
#
# Recommended flow:
#   1. Deploy with local auth → log in → set up your team
#   2. Add OAuth credentials below
#   3. Clear SELF_HOST_LOCAL_AUTH_EMAIL and SELF_HOST_LOCAL_AUTH_PASSWORD
#   4. rm .env && ./setup.sh && ./up.sh
#   → Local auth is now disabled, only OAuth works.
SELF_HOST_LOCAL_AUTH_EMAIL=admin@example.com
SELF_HOST_LOCAL_AUTH_PASSWORD=changeme

# GitHub OAuth (optional — add when ready)
#   Create an OAuth app at https://github.com/settings/developers
#   Set the callback URL to: <APP_URL>/v1/oauth/github/callback
GITHUB_OAUTH_CLIENT_ID=
GITHUB_OAUTH_CLIENT_SECRET=

# Google OAuth (optional — add when ready)
#   Create credentials at https://console.cloud.google.com/apis/credentials
#   Set the redirect URI to: <APP_URL>/v1/oauth/google/callback
GOOGLE_OAUTH_CLIENT_ID=
GOOGLE_OAUTH_CLIENT_SECRET=


# ========================== TLS & NETWORKING ================================
# The built-in nginx proxy with self-signed certs.
# Set PROXY_ENABLED=false if you handle TLS yourself (e.g. Caddy, Cloudflare,
# an external nginx, etc.) and just want the raw app/relay on their ports.

PROXY_ENABLED=true
BIND_ADDR=0.0.0.0
HTTPS_PORT=443
RELAY_PORT=8443

# Self-signed cert settings (only used when PROXY_ENABLED=true)
CERT_DAYS=1825
CERT_KEY_BITS=2048

# Extra Subject Alternative Names for the self-signed cert.
# Useful when an external proxy sits in front of the built-in nginx and
# connects to it by a different hostname or IP than what's in APP_URL.
# Space-separated list of IPs or DNS names. Leave empty if not needed.
#
# Example: CERT_EXTRA_SANS="192.168.1.177 10.0.0.5 kanban.local"
CERT_EXTRA_SANS=""


# ========================== EVERYTHING BELOW IS OPTIONAL ====================
# Leave values empty to disable. The server works fine without any of these.
# ============================================================================


# --- Email notifications (Loops) -------------------------------------------
# Sign up at https://loops.so to get an API key.
# Without this, invites still work — you just share the link manually
# (use ./invite.sh to get pending invite links).
LOOPS_EMAIL_API_KEY=
LOOPS_INVITE_TEMPLATE_ID=
LOOPS_REVIEW_READY_TEMPLATE_ID=
LOOPS_REVIEW_FAILED_TEMPLATE_ID=
DIGEST_ENABLED=false

# --- GitHub App integration ------------------------------------------------
# Enables deeper GitHub integration (webhooks, automated actions).
# See https://docs.github.com/en/apps/creating-github-apps
GITHUB_APP_ID=
GITHUB_APP_PRIVATE_KEY=
GITHUB_APP_WEBHOOK_SECRET=
GITHUB_APP_SLUG=

# --- File attachments (Azure Blob Storage) ----------------------------------
# Enables file uploads on issues. Works with Azure Blob Storage or any
# S3-compatible service (e.g. MinIO) via the endpoint URL override.
AZURE_STORAGE_ACCOUNT_NAME=
AZURE_STORAGE_ACCOUNT_KEY=
AZURE_STORAGE_CONTAINER_NAME=issue-attachments
AZURE_STORAGE_ENDPOINT_URL=
AZURE_STORAGE_PUBLIC_ENDPOINT_URL=
AZURE_MANAGED_IDENTITY_CLIENT_ID=
AZURE_BLOB_PRESIGN_EXPIRY_SECS=

# --- Code review artifacts (Cloudflare R2) ----------------------------------
# Stores review output. Only needed if you use the review feature.
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_REVIEW_ENDPOINT=
R2_REVIEW_BUCKET=
R2_PRESIGN_EXPIRY_SECS=
REVIEW_WORKER_BASE_URL=
REVIEW_DISABLED=false

# --- Billing (Stripe) ------------------------------------------------------
# Only relevant if you want to charge for team seats.
STRIPE_SECRET_KEY=
STRIPE_TEAM_SEAT_PRICE_ID=
STRIPE_WEBHOOK_SECRET=
STRIPE_FREE_SEAT_LIMIT=1

# --- Observability ----------------------------------------------------------
# Error tracking and analytics. Totally optional.
SENTRY_DSN_REMOTE=
POSTHOG_API_KEY=
POSTHOG_API_ENDPOINT=
APPLICATIONINSIGHTS_CONNECTION_STRING=
RUST_LOG=info,remote=info

# --- Source repo ------------------------------------------------------------
REPO_URL=https://github.com/BloopAI/vibe-kanban.git
REPO_DIR=vibekanban
