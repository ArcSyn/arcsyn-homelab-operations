# Security and Publication Boundary

This repository is a portfolio-safe view of a private personal homelab. It is intentionally incomplete from an operational-security perspective: enough implementation detail is retained to demonstrate real troubleshooting, monitoring, backup, and recovery work, while live infrastructure data stays private.

## Never commit

Do not add any of the following to this repository:

- passwords, API keys, tokens, recovery codes, or private keys
- `.env` files or secret-bearing runtime configuration
- private IP addresses, Tailscale addresses, or private hostnames
- live Push/monitor URLs or authentication-bearing service URLs
- personal media, user-generated content, or family information
- production databases, SQLite/WAL/SHM files, application state, or raw exports
- backup archives, checksum sidecars tied to private archive names, or restore snapshots
- raw logs or screenshots containing private endpoints, usernames, paths, messages, or credentials
- exact live filesystem layout when it is not necessary to explain the technical work

## Portfolio derivative policy

Public-facing scripts in this repository must be traceable to a real private source revision. When a private value must be removed, prefer one of these approaches:

1. externalize it as a required configuration value;
2. redact it explicitly in documentation; or
3. omit the artifact if removing the private value would make the technical claim misleading.

Do not invent substitute servers, fake incidents, mock production data, fabricated metrics, or fictional deployment results.

## Validation before publication

Before changing repository visibility or treating a branch as portfolio-ready:

- review the complete diff;
- run syntax/static checks appropriate to the files;
- scan for credentials and private-key material;
- scan for RFC1918/private/Tailscale-style addresses and private hostnames;
- scan for live absolute paths and usernames;
- check documentation for personal/media information;
- verify every numerical result against its provenance record;
- preserve limitations and evidence status.

## Scope boundary

This repository documents **personal homelab experience**. It must not be described as enterprise production ownership or professional IT employment.

AI tools were used for research, diagnostics, troubleshooting, planning, testing design, implementation assistance, and documentation. Public material should remain understandable and explainable without presenting AI-assisted work as entirely unaided authorship.
