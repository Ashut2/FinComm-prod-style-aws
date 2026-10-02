# Impact log

One line per measurement. Rule: a number goes here only if I measured it myself and can name where.
Projections go in the second table and always show their assumptions.

## Measured (my own results)

| Date | What | Result | Evidence |
|---|---|---|---|
| 2026-10-02 | product-catalog Docker build, cold (`--no-cache`) | 102.6 s | `docs/notes/docker-layer-cache-test.md` |
| 2026-10-02 | Same build, nothing changed | 3.76 s (about 27x faster) | same |
| 2026-10-02 | Same build after a one-line `main.go` edit | 28.06 s (about 3.7x faster, about 75 s saved) | same |
| 2026-09-29 | product-catalog image size, single-stage | 1.35 GB | Docker Desktop, `fincomm/product-catalog:dev` |
| 2026-09-30 | Containerised service serving real data from Postgres | 10 products returned | `scripts/product-catalog/verify_data.py` |
| 2026-10-01 | Container-name DNS, user-defined network vs default bridge | resolves vs "bad address" | Block 2 notes, tracker 1 Oct |
| 2026-09-02 | Incident #001: SSH failure, 2 root causes | about 5 h to diagnose (my own estimate) | `docs/incident-temp/incident-001-ssh-timeout.md` |
| 2026-09 | Network layer defined as code | 9 Terraform resources, remote state in S3 | `terraform/vpc_foundations/` |

## Pending measurements (capture when they happen)
- Image size after the multi-stage build (Block 3), the "after" for the 1.35 GB.
- Time to bring up the full stack with one command (Compose, Block 3).
- Time to rebuild the VPC from scratch with `terraform apply`.
- Monthly AWS cost of the running stack.

## Projections (assumptions stated, not measured)

| Claim | Assumptions | Result |
|---|---|---|
| Cached builds save team time | 50 builds/day, warm cache, 75 s saved each | about 62 min/day |

Caveat: CI runners often start with a cold cache, so the real saving can be lower. Say so when presenting it.

## Never claim
- Revenue, users, uptime, or cost savings. This project has none of these.
- Anything that sounds like a company outcome without saying it's a projection.
