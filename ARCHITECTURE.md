# How it works

## Overview

```mermaid
graph TB
    subgraph server["Your Server"]
        proxy["Reverse Proxy<br/>(nginx)<br/>:443 → app | :8443 → relay"]
        app["App Server<br/>(remote)<br/>:8081"]
        relay["Relay Server<br/>(tunnel)<br/>:8082"]
        db[(Postgres)]
        electric["ElectricSQL<br/>(real-time sync)"]

        proxy --> app
        proxy --> relay
        app --> db
        relay --> db
        electric --> db
        app --> electric
    end

    browser["Browser<br/>(Web UI)"]
    browser -->|HTTPS| proxy

    dev["Developer's Machine<br/>(npx vibe-kanban)"]
    dev -->|WebSocket| proxy
```

## How the relay tunnel works

The relay lets the web UI control local machines that aren't directly reachable (behind NAT, firewalls, etc.).

```mermaid
sequenceDiagram
    participant dev as Developer's Machine<br/>(npx vibe-kanban)
    participant relay as Relay Server
    participant browser as Browser (Web UI)

    dev->>relay: 1. Connect via WebSocket<br/>/v1/relay/connect
    relay-->>dev: 2. Registered (machine ID + name)

    browser->>relay: 3. User opens a workspace
    relay->>dev: 4. Forward request via<br/>yamux stream over WebSocket
    dev->>relay: 5. Local server responds
    relay->>browser: 6. Response tunnelled back
```

**Key points:**
- The local machine connects *outward* to the relay — no inbound ports needed
- One long-lived WebSocket carries all traffic via multiplexing (yamux)
- The relay server authenticates connections using the same JWT as the app
- Multiple local machines can connect simultaneously, each with a unique ID

## Data flow

```mermaid
graph LR
    browser["Browser"] -->|HTTPS| app["App Server"]
    app --> db[(Postgres)]
    electric["ElectricSQL"] <--> db
    app --> electric

    browser2["Browser"] -->|HTTPS| relay["Relay Server"]
    relay -->|WebSocket| dev["Developer's Machine"]
```

- **App server** handles auth, API, and serves the web UI
- **ElectricSQL** syncs data in real-time between Postgres and connected clients
- **Relay server** tunnels HTTP traffic to local machines for remote access
- **Postgres** stores everything — users, orgs, projects, issues, invitations
