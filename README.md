# ArcSyn Homelab Operations

Evidence-backed documentation and portfolio-safe derivatives from a real personal Debian homelab used for hands-on IT support and systems practice.

## What this repository demonstrates

- Debian Linux administration in a personal homelab
- Docker Compose service operation and health validation
- SSH and private remote-access workflows
- service and container troubleshooting using health checks and logs
- disk-capacity monitoring with warning and critical thresholds
- critical-backup validation with checksum and archive-safety checks
- offline SQLite integrity validation
- isolated application recovery testing without altering the running service
- recurring validation and failure/recovery monitoring

This is **hands-on homelab experience**, not enterprise production ownership or professional IT employment.

## Evidence status

The material here is derived from tracked private source and recorded runtime validation. Public-facing files intentionally remove private addresses, hostnames, exact storage paths, credentials, personal media, and other sensitive infrastructure details.

- **Verified live** — behavior was observed on the homelab or recorded by a merged change with runtime validation.
- **Portfolio-safe derivative** — real operational logic with private values externalized or redacted for publication.
- **Not included** — unfinished or insufficiently verified work is kept out of this repository.

The GitHub activity collector/work-ledger project remains work in progress and is intentionally excluded.

## Repository map

- [`docs/architecture.md`](docs/architecture.md) — sanitized architecture and operational flow
- [`scripts/check-lab-health.portfolio.sh`](scripts/check-lab-health.portfolio.sh) — portfolio-safe derivative of the real health-check logic
- [`scripts/check-disk-space.portfolio.sh`](scripts/check-disk-space.portfolio.sh) — portfolio-safe derivative of the real disk-space monitor
- [`docs/case-studies/backup-validation-and-isolated-restore.md`](docs/case-studies/backup-validation-and-isolated-restore.md) — verified backup/recovery case study
- [`PROVENANCE.md`](PROVENANCE.md) — private-source revision and redaction record for each public artifact
- [`SECURITY.md`](SECURITY.md) — publication boundary and excluded data

## AI assistance disclosure

AI tools were used as part of the workflow for research, diagnostics, troubleshooting, implementation planning, testing design, and documentation. The underlying homelab work was performed and validated on the personal lab, and this repository is intentionally limited to claims and artifacts that can be traced to evidence and explained in an interview.

## Current scope

This repository focuses on the strongest completed evidence: homelab operations, health checks, disk monitoring, backup validation, isolated recovery, and monitoring. Experimental projects and incomplete deployment work are deliberately excluded until they reach a stable, defensible checkpoint.
