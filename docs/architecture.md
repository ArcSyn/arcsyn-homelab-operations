# Homelab Architecture

## Scope

This document is a sanitized view of the actual ArcSyn personal homelab. It keeps the service roles and operational relationships that are useful to an IT-support reviewer while omitting private hostnames, addresses, credentials, exact storage paths, and personal media details.

## High-level layout

```text
Personal client devices
        |
        | private remote access / SSH
        v
Debian homelab host
        |
        +-- Docker / Docker Compose
        |     +-- Open WebUI
        |     +-- SearXNG
        |     +-- Homepage
        |     +-- Uptime Kuma
        |     +-- Jellyfin
        |
        +-- systemd services and timers
        |     +-- health validation
        |     +-- disk-capacity checks
        |     +-- backup validation
        |
        +-- critical backup workflow
              +-- checksum verification
              +-- archive-safety inspection
              +-- offline SQLite integrity checks
              +-- isolated recovery testing
              +-- off-host copy validation

External compute worker
        |
        +-- Ollama model service reachable privately from the lab
```

## Operational model

### Service operation

Containerized applications run on the Debian host. The operational health check validates both host-level services and application-level behavior instead of treating a running container as sufficient evidence of health.

Checks used in the private operational script include:

- Docker, Tailscale, and nftables service state
- selected container running state
- application health endpoints
- communication between dependent containers
- reachability of a separate model-serving worker
- disk-capacity status

The publication-safe script in this repository preserves that logic but externalizes private URLs and absolute paths.

### Monitoring

Disk monitoring evaluates configured filesystems against warning and critical thresholds and returns a nonzero status for critical conditions. Uptime Kuma was used for service monitoring and controlled failure/recovery notification tests.

### Backup and recovery

The critical-backup workflow separates backup creation from recovery validation. Validation checks the archive before any restore attempt, including checksum verification, unsafe archive-member rejection, isolated extraction, and read-only SQLite integrity checks.

A stateful Uptime Kuma copy was restored in an isolated environment and verified healthy without modifying the production container or production data. See the case study for the evidence boundary.

## Security boundary

This repository intentionally does not publish:

- private IP or Tailscale addresses
- private hostnames or service URLs
- credentials, tokens, environment files, or recovery codes
- exact live storage paths where disclosure is unnecessary
- personal media, databases, archives, or logs
- internal family or user information

The private operational repository remains private. This repository contains only reviewed portfolio-safe derivatives and summaries.
