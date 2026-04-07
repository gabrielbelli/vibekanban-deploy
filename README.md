# vibekanban-deploy

Self-hosted [Vibe Kanban](https://github.com/BloopAI/vibe-kanban) on your LAN with self-signed HTTPS.

## Quick start

```bash
./setup.sh              # clones repo, generates secrets + cert
vim .env                # add your GitHub OAuth credentials
./up.sh                 # builds and starts everything
```

Open `https://<your-lan-ip>` and accept the cert warning.

## Scripts

| Script | What it does |
|--------|-------------|
| `setup.sh` | Clones vibekanban, generates `.env` and self-signed cert |
| `up.sh` | Starts all containers (pass `--build` to rebuild) |
| `down.sh` | Stops all containers (pass `--volumes` to delete data) |
| `logs.sh` | Tails container logs (pass service name to filter) |
| `invite.sh` | Lists pending invite links (no email service needed) |

## Authentication

Set at least one in `.env`:

**GitHub OAuth** — create an app at https://github.com/settings/developers with callback URL `https://<LAN_IP>/v1/oauth/github/callback`, then set `GITHUB_OAUTH_CLIENT_ID` and `GITHUB_OAUTH_CLIENT_SECRET`.

**Local auth** — set `SELF_HOST_LOCAL_AUTH_EMAIL` and `SELF_HOST_LOCAL_AUTH_PASSWORD` for a bootstrap admin account.

## Connect local machines

On each developer's machine:

```bash
VK_SHARED_API_BASE=https://<LAN_IP> \
VK_SHARED_RELAY_API_BASE=https://<LAN_IP>:8443 \
npx vibe-kanban
```

After logging in, the relay tunnel connects automatically — the remote web UI can control local git repos.

Visit `https://<LAN_IP>:8443` once in the browser to accept the cert warning for the relay endpoint.

## Updating

```bash
cd vibekanban && git pull && cd ..
./up.sh --build
```

## Ports

| Port | Service |
|------|---------|
| 443 | Web UI |
| 8443 | Relay tunnel |
