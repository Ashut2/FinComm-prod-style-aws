# FinComm-prod-style-aws

FinCommerce - Production-Style E-Commerce Platform on AWS

## Problem

Build and operate a production-style e-commerce platform on AWS, demonstrating
Infrastructure as Code, containerization, Kubernetes orchestration, CI/CD,
observability, and incident response - as a hands-on portfolio project, not
a tutorial reproduction.

## Results so far (measured, see [`docs/impact/impact-log.md`](docs/impact/impact-log.md))

| What | Result |
|---|---|
| Container image size, single-stage vs multi-stage on `scratch` | 1.35 GB -> 33.1 MB (about 40x smaller) |
| Docker rebuild after a one-line code edit, bad vs good instruction order | 55.0 s vs 28.06 s; fully cached rebuild 3.76 s |
| Full stack (Postgres + service) from nothing with one command | 7.05 s (one run, warm cache; excludes image build) |

> One command brings up my Go service and Postgres in about 7 seconds, with data on a volume and a healthcheck so the app waits for the database.

## What is built

- **AWS, as code (Terraform):** VPC, public subnet, Internet Gateway, route table, security group and an EC2 instance, with remote state in S3. An IAM layer is planned and plan-checked, not applied.
- **Containers (Docker + Compose, runs locally):** a Go gRPC service (`product-catalog`, taken from the OpenTelemetry demo and containerised by me) and PostgreSQL 18 in a container with a persistent volume, started with one command. The containers are not deployed to AWS yet.

## Quick start (local containers)

```bash
cp docker/.env.example docker/.env      # then fill in the values
docker compose -f docker/docker-compose.yaml up -d --wait
cd scripts/product-catalog && pip install grpcio protobuf && python verify_data.py
```
Expected: `number of products: 10`. Stop with `docker compose -f docker/docker-compose.yaml down` (add `-v` to also delete the database volume).

## Architecture

See [`architecture/architecture.md`](architecture/architecture.md) for the v1 diagram and [`docs/concepts/mental-model.md`](docs/concepts/mental-model.md) for how the pieces link.

navigate to `/docs/adr` for Architecture Decision reports

Current scope: two independent Terraform projects, each with its own S3-backed
state file:
- `terraform/ec2_app/` - EC2 instance provisioned via a reusable module
- `terraform/vpc_foundations/` - VPC networking layer (public tier only)

They are wired together: `ec2_app` reads `vpc_foundations` outputs
(`public_subnet_id`, `app_sg_id`) via `terraform_remote_state`, so the EC2
instance launches into the custom VPC.

## Tech Stack

- **IaC:** Terraform (`hashicorp/aws` provider v6.58.0)
- **Cloud:** AWS (EC2, VPC, S3)
- **Containers:** Docker (multi-stage builds), Docker Compose (healthchecks, named volume)
- **App layer:** Go gRPC service (from the OpenTelemetry demo), PostgreSQL 18
- **State management:** S3 remote backend with versioning enabled, separate
  state keys per project
- **Environment:** Git Bash (MINGW64) on Windows

## Current Status

**Week 1–3: Terraform foundations + networking - in progress**

- [x] Terraform fundamentals: resources, variables, outputs, data sources
- [x] Reusable module built (`modules/ec2-instances/`)
- [x] Three-layer validation understood: provider-level, schema-level,
      remote API-level (documented in troubleshooting notes)
- [x] State drift behavior tested and understood
- [x] Remote backend (S3) configured and state migrated
- [ ] DynamoDB state locking — not yet implemented
- [x] VPC + public subnet + Internet Gateway + route table (public tier only)
- [ ] Private subnet + NAT Gateway — not yet built
- [x] EC2 instance connected to custom VPC (via remote state outputs)
- [x] Security group applied (SSH from my IP, HTTP open); NACLs - theory only

**Containers (Docker block): in progress**

- [x] Single-stage Dockerfile, layer-cache and volume experiments, container networking
- [x] Multi-stage build on `scratch` (1.35 GB -> 33.1 MB), verified with a gRPC client
- [x] Docker Compose: app + Postgres, named volume, `init.sql`, healthcheck with `depends_on: service_healthy`
- [ ] Push image to a registry (ECR)
- [ ] CI pipeline that builds the image
- [ ] Kubernetes, observability: planned

## How to Run

**EC2 instance (via module):**
```bash
cd terraform/ec2_app
terraform init
terraform plan
terraform apply
```

**VPC foundations:**
```bash
cd terraform/vpc_foundations
terraform init
terraform plan
terraform apply
```

Both destroy cleanly with `terraform destroy` - no persistent infrastructure
is kept running between sessions. VPC-layer resources (VPC, subnets, route
tables, IGW) carry no idle cost; the EC2 instance does, so it's torn down
immediately after each test.

## What I Learned

- Terraform validates config in layers: provider-level and schema-level
  errors surface at `plan`, but remote API-level errors (like an invalid
  `instance_type`) only appear at `apply`, since Terraform can't validate
  every possible AWS-side value locally.
- Terraform state stores the *entire* resource as AWS reports it — not
  just the fields you configured. This is what makes drift detection
  possible.
- A module folder must never contain its own `provider` block, `.terraform/`,
  or state — those belong at the root only, or the module silently becomes
  an independent Terraform project.
- Migrating a backend requires care: `-migrate-state` preserves existing
  state, while `-reconfigure` starts fresh and can silently orphan tracked
  resources if used carelessly.
- AWS reserves 5 IP addresses *within each individual subnet* (network,
  router, DNS, future-use, broadcast) — this reservation resets per subnet,
  it doesn't consume address space cumulatively across a VPC's subnet range.
- 
