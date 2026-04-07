# How it works

## Overview

```
┌─────────────────────────────────────────────────────────┐
│                     Your Server                         │
│                                                         │
│  ┌──────────┐   ┌──────────┐   ┌────────────────────┐  │
│  │ Postgres │◄──┤   App    │──►│    ElectricSQL      │  │
│  │   (db)   │◄──┤ (remote) │   │ (real-time sync)    │  │
│  └────┬─────┘   └────┬─────┘   └────────────────────┘  │
│       │              │ :8081                             │
│       │         ┌────┴─────┐                            │
│       └────────►│  Relay   │                            │
│                 │ (tunnel) │                            │
│                 └────┬─────┘                            │
│                      │ :8082                            │
│  ┌───────────────────┴──────────────────────────────┐   │
│  │           Reverse Proxy (nginx)                  │   │
│  │         :443 → app    :8443 → relay              │   │
│  └──────────────────────────────────────────────────┘   │
└───────────────┬─────────────────────┬───────────────────┘
                │                     │
          ┌─────┴──────┐        ┌─────┴──────┐
          │  Browser   │        │  Browser   │
          │  (Web UI)  │        │  (Web UI)  │
          └────────────┘        └────────────┘
```

## How the relay tunnel works

The relay lets the web UI control local machines that aren't directly reachable (behind NAT, firewalls, etc.).

```
 Developer's machine                Your Server                 Browser
┌──────────────────┐     ┌─────────────────────────┐     ┌──────────────┐
│                  │     │                         │     │              │
│  npx vibe-kanban │     │       Relay Server      │     │   Web UI     │
│                  │     │                         │     │              │
│  1. Connects ────────► │  WebSocket at           │     │              │
│     via WebSocket│     │  /v1/relay/connect      │     │              │
│                  │     │                         │     │              │
│                  │     │  2. Registers machine   │     │              │
│                  │     │     with ID + name      │     │              │
│                  │     │                         │     │              │
│                  │     │         ◄──────────────────── │ 3. User opens │
│                  │     │           HTTP request   │     │    workspace │
│                  │     │                         │     │              │
│  4. Relay sends  │◄── │  Forwards request via   │     │              │
│     request to   │     │  yamux stream over the  │     │              │
│     local server │     │  existing WebSocket     │     │              │
│                  │     │                         │     │              │
│  5. Local server │───► │  Response tunnelled     │────►│ 6. UI shows  │
│     responds     │     │  back through relay     │     │    result    │
│                  │     │                         │     │              │
└──────────────────┘     └─────────────────────────┘     └──────────────┘
```

**Key points:**
- The local machine connects *outward* to the relay — no inbound ports needed
- One long-lived WebSocket carries all traffic via multiplexing (yamux)
- The relay server authenticates connections using the same JWT as the app
- Multiple local machines can connect simultaneously, each with a unique ID

## Data flow

```
Browser ──► App Server ──► Postgres
                │               ▲
                │               │
                ▼               │
           ElectricSQL ─────────┘
           (real-time sync)

Browser ──► Relay Server ──(WebSocket)──► Developer's machine
```

- **App server** handles auth, API, and serves the web UI
- **ElectricSQL** syncs data in real-time between Postgres and connected clients
- **Relay server** tunnels HTTP traffic to local machines for remote access
- **Postgres** stores everything — users, orgs, projects, issues, invitations
