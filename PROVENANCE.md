# Provenance Record

This repository contains portfolio-safe derivatives and summaries of real private ArcSyn homelab work. The private operational repository remains private. This file records the source revision, evidence status, and publication changes for each artifact.

## Evidence vocabulary

- **Verified live** — runtime behavior was observed on the homelab or recorded in merged change evidence.
- **Repository source** — exact tracked source file used as the basis for a public derivative.
- **Portfolio-safe derivative** — real source logic retained while private identifiers or environment-specific values are externalized.

## Artifact map

### `README.md`

**Basis:** Private `ArcSyn/arcsyn-ai-lab` repository, merged ARC-LAB operational work, and the reviewed portfolio provenance audit.

**Evidence represented:** Debian homelab operations, Docker/Compose services, private remote access, health checks, disk monitoring, backup validation, recovery testing, and monitoring.

**Publication changes:** Removed private infrastructure identifiers and excluded the active GitHub collector/work-ledger WIP.

### `docs/architecture.md`

**Basis:** Private homelab service layout plus the tracked health-check and backup/recovery workflows.

**Evidence represented:** Debian host, Docker/Compose application layer, systemd-driven operational checks, separate model-serving worker, and critical-backup validation flow.

**Publication changes:** Removed hostnames, private addresses, exact ports/URLs, credentials, personal media details, and unnecessary absolute paths.

### `scripts/check-lab-health.portfolio.sh`

**Private source:** `scripts/check-lab-health.sh`

**Original pinned source revision:** `ed1236295087b1acb26cf4f42ee5e39cd93dbb58`

**Original pinned source blob:** `bc6ae709ec5541d45f3e04da56898b9c7eab9b40`

**Evidence status:** Real operational health-check logic from the private homelab source, with one reviewed correctness correction applied to the portfolio derivative while the equivalent private-source fix is under review.

**Correctness correction:** The original source used `docker inspect -f '{{.State.Running}}'` directly through a generic exit-status wrapper. Docker can successfully inspect an existing stopped container and print `false`, which allowed a false PASS. The derivative now uses an explicit predicate that succeeds only when the inspected value is exactly `true`. A disposable command-mock regression covers running, stopped, and missing states for every represented container check.

**Publication changes:**

- external worker address replaced by required `EXTERNAL_OLLAMA_URL` configuration;
- application health URLs externalized;
- internal search URL externalized;
- private absolute disk-check path externalized through `DISK_CHECK_SCRIPT`;
- container-running checks changed to require an exact `true` state rather than successful inspection alone;
- service/container checks, pass/fail accounting, external-worker skip behavior, dependency checks, and failure exit behavior retained.

The public derivative is intentionally not described as byte-identical or as a production replacement.

### `scripts/check-disk-space.portfolio.sh`

**Private source:** `scripts/check-disk-space.sh`

**Pinned source revision:** `de0ca043e4d6dc5b67ad25a251f49d029ed6cace`

**Pinned source blob:** `38db4dc2fe4f1453d41bbb23a700471051b4830e`

**Evidence status:** Tracked disk-capacity implementation with live-use support in ARC-LAB monitoring records.

**Publication changes:**

- live filesystem paths replaced by required newline-delimited `ARCSYN_DISK_PATHS` configuration;
- live status-file path externalized;
- original 80% warning and 90% critical defaults retained;
- missing-path handling, `df` parsing, human-readable available capacity, overall-state logic, and critical exit code `2` retained.

### `docs/case-studies/backup-validation-and-isolated-restore.md`

**Private source:** `docs/ARC-LAB-05-BACKUP-RECOVERY.md`

**Pinned merged revision:** `c2f313395252297f65c47443b6998714122dee3f`

**Pinned source blob:** `613da8759f90127834c605b9a129b082d8c06751`

**Evidence status:** Verified ARC-LAB-05 backup/recovery exercise.

**Verified source results represented:**

- 616 archive members: 401 regular files and 215 directories;
- approximately 21.1 MiB declared regular-file data;
- off-host copy verified byte-identical to the Debian source archive;
- four expected SQLite integrity checks passed;
- isolated Uptime Kuma stateful restore became healthy and returned HTTP 200;
- production service remained unchanged during the recovery drill;
- recurring validation installation/activation and controlled failure/recovery monitoring transitions were verified.

**Publication changes:** Removed the exact archive filename, digest, live paths, monitor endpoint/provider details, internal port numbers, and private infrastructure identifiers.

**Limitations preserved:** This did not prove a bare-metal rebuild or restoration of every homelab application.

### `SECURITY.md`

**Basis:** Publication boundary from the private repository and portfolio provenance review.

**Purpose:** Make explicit what this public-facing evidence repository must never contain.

## Deferred evidence

The GitHub activity collector and SQLite work ledger are intentionally not exported here. They remain active work in progress and are not represented as complete portfolio projects.

Immich-specific troubleshooting noise is also excluded from the current portfolio scope because stronger, cleaner evidence already exists.
