FinComm-prod-style-aws
FinCommerce - Production-Style E-Commerce Platform on AWS

# FinComm-prod-style-aws

FinCommerce - Production-Style E-Commerce Platform on AWS

## Problem

Build and operate a production-style e-commerce platform on AWS, demonstrating
Infrastructure as Code, containerization, Kubernetes orchestration, CI/CD,
observability, and incident response — as a hands-on portfolio project, not
a tutorial reproduction.

## Architecture

*Diagram coming — planned for Week 3 review (v1) once VPC/networking layer
is in place.*

Current scope: a single EC2 instance provisioned via a reusable Terraform
module, with remote state management on S3.

## Tech Stack

- **IaC:** Terraform (`hashicorp/aws` provider v6.58.0)
- **Cloud:** AWS (EC2, S3)
- **State management:** S3 remote backend with versioning enabled
- **Environment:** Git Bash (MINGW64) on Windows

## Current Status

**Week 1–2: Terraform foundations — in progress**

- [x] Terraform fundamentals: resources, variables, outputs, data sources
- [x] Reusable module built (`modules/ec2-instances/`)
- [x] Three-layer validation understood: provider-level, schema-level,
      remote API-level (documented in troubleshooting notes)
- [x] State drift behavior tested and understood
- [x] Remote backend (S3) configured and state migrated
- [ ] DynamoDB state locking — not yet implemented
- [ ] VPC / networking layer — next (Week 3)

## How to Run

```bash
cd terraform/local_state
terraform init
terraform plan
terraform apply
```

Destroys cleanly with `terraform destroy` — no persistent infrastructure
is kept running between sessions.

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
