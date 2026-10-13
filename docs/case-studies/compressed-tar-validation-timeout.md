# Engineering case study: a backup validation that hit its 40-minute limit

**Status:** Verified on a personal Debian homelab; public-facing, redacted summary of a bounded production repair. This is *not* a full disaster-recovery certification or an identical-input benchmark.

## Why it mattered

A recurring deep backup-validation job had previously passed on a smaller archive, but subsequent runs repeatedly reached their configured execution limit. A backup that exists is not the same thing as a backup that can be checked and recovered within a useful operating window.

The job was intentionally constrained to **40 minutes inside a 45-minute systemd boundary**. Increasing those limits would have hidden the underlying performance problem and weakened the operational signal.

## Investigation

The deep validator safely inspects a compressed tar archive and checks extracted SQLite databases in an isolated temporary directory. The extraction pass originally visited selected tar members in a logical path/depth order. That order did **not** necessarily match the physical order of members in the gzip-compressed tar stream.

Random access through a compressed tar stream can require expensive backwards seeks and re-decompression. Repeating that work thousands of times is a plausible explanation for a validator spending far more time in extraction than expected.

The correction was narrow:

- Preserve archive safety screening and the existing member map.
- Extract allowable members in their **physical tar-offset order** instead of path/depth order.
- Retain the same bounded runtime and the same four SQLite integrity checks.
- Verify the exact corrected Python source against a reviewed SHA-256 before installation.

This changes visitation order, not which archive members are considered safe.

## Controlled deployment and test

The original immutable validator release remained unchanged. The corrected validator was installed as a separate, verified artifact, selected only for the deep-validation service through a systemd environment override. Nightly backup generation and lightweight validation were left on their established paths.

On the next one-time, owner-approved deep-validation run, the operator observed:

| Check | Observed result |
| --- | --- |
| Archive | Current critical homelab archive |
| Elapsed time | Approximately **42 seconds**, from service start to exit |
| Service result | Successful exit, status 0 |
| Temporary extraction | PASS; cleanup reported complete |
| Files extracted | **9,550** |
| Open WebUI application SQLite | `PRAGMA integrity_check` returned `ok` |
| Open WebUI vector-store SQLite | `ok` |
| Uptime Kuma SQLite | `ok` |
| Jellyfin SQLite | `ok` |
| Final validation report | **PASS**, no reported failures |

Earlier scheduled deep validations on other archives had reached the 40-minute cutoff. The new run completing in about 42 seconds provides strong operational evidence that the extraction-order change addressed this failure mode.

**It is not a controlled speedup ratio:** the previous failed runs and this passing run did not use the same exact archive under otherwise identical conditions.

## Safety and operational lessons

1. **Optimize the failure mechanism before raising limits.** The 40-minute validator timeout and outer systemd boundary were retained.
2. **Separate fix delivery from workload execution.** Installation did not start a deep restore test; the operator approved that separately.
3. **Keep the old artifact intact.** A versioned release plus scoped environment selection made rollback straightforward.
4. **Validate the recovered data, not just the tar command.** All four expected SQLite integrity checks passed after extraction.
5. **Treat logs as evidence, not marketing.** The final report supports a successful deep validation of one current archive; it does not establish a full-host recovery or every application's functional restore.

## Boundaries of the published account

This write-up intentionally omits live hostnames, private network endpoints, file-system paths, archive identifiers, monitor tokens, raw logs, and user data. Source-control evidence and the full operational run report are retained in the private infrastructure repository. The observations above derive from that operator-verified run; the public repository does not contain the production validator or its private deployment instructions.

See also [Backup Validation and Isolated Restore](backup-validation-and-isolated-restore.md) for the earlier independent application-restoration drill.
