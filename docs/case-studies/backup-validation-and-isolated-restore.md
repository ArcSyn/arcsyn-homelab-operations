# Backup Validation and Isolated Restore

## Objective

Verify that a real critical homelab backup could be read safely and that selected application state could be validated or restored without writing over the running environment.

## Evidence status

**Verified live / merged runtime evidence.** The source procedure and results were merged in ARC-LAB-05 after validation on the Debian homelab.

## What was tested

The recovery workflow validated a real critical archive using a fail-closed Python validator built around the standard library. Before extraction, the validator checked the SHA-256 record and rejected unsafe archive conditions such as absolute paths, traversal, duplicate normalized paths, links, special files, sparse members, and protected extraction destinations.

The verified archive contained:

- 616 members
- 401 regular files
- 215 directory records
- approximately 21.1 MiB of declared regular-file data
- no symbolic links, hard links, special members, or duplicate normalized paths

A separate off-host copy was independently checked and confirmed byte-identical to the Debian copy by filename, length, and digest.

## Offline database validation

After safe isolated extraction, four expected SQLite databases were opened read-only/immutable and checked with `PRAGMA integrity_check`:

- Open WebUI application database
- Open WebUI vector-store SQLite database
- Uptime Kuma database
- Jellyfin database

All four integrity checks returned `ok`.

The validation deliberately avoided printing application rows, credentials, environment contents, user-generated content, or personal media filenames.

## Isolated stateful restore

Uptime Kuma was selected for a functional recovery drill because it provided a stateful service whose restored behavior could be verified without replacing the production instance.

The restored copy was started in an isolated environment and:

1. became healthy;
2. returned HTTP 200 on its loopback check;
3. retained SQLite integrity after the test;
4. generated test-only heartbeat rows inside the disposable copy;
5. left the production container identity, runtime, mounts, network state, and health unchanged; and
6. was removed along with its temporary network and recovery data after validation.

This demonstrated one real application-level recovery path rather than only proving that an archive file could be decompressed.

## Recurring validation

The reviewed recovery package also added recurring lightweight and deep validation using systemd services and timers. The installed scripts and units were verified against reviewed source hashes. A controlled failure produced the expected monitoring DOWN transition, a controlled success produced recovery, and a subsequent legitimate lightweight validation passed without extraction.

## What this proves

The exercise provides evidence that:

- the tested critical archive was readable and checksum-valid;
- the off-host copy matched the source archive;
- unsafe archive structures were screened before extraction;
- four included SQLite databases passed offline integrity checks;
- one stateful application could start and behave correctly from an isolated restored copy; and
- the recovery test did not alter the production service.

## What this does not prove

This was not a bare-metal rebuild and did not prove full restoration of every homelab application. Open WebUI, Jellyfin, AdGuard, and other services were not individually restored as part of this exercise. Those limitations are preserved intentionally rather than being represented as completed work.

## Publication boundary

Exact archive names and hashes, private paths, monitor endpoints, provider details, and internal network identifiers are intentionally omitted here. The public summary preserves the verified method and results without publishing live infrastructure details.
