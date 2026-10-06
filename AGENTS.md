# FinComm — production-style AWS project

A learning project. The owner must be able to explain every concept and resource to anyone, and will record a demo video. Optimise for **understanding first, speed second**. Also owner should be able to explain the business impact , this project would have by the end of this project using numbers, facts & Impact in the narrative.

## Layout
- `terraform/vpc_foundations/` — network layer (VPC, public subnet, IGW, route table, security groups). State: S3 `fincomm-tfstate-ashu2026`, region `ap-south-1`.
- `terraform/ec2_app/` — EC2 root module calling `modules/ec2-instances`; reads VPC outputs via `terraform_remote_state`. (Renamed from `local_state`; its S3 state key is still `fincomm/local_state/terraform.tfstate` on purpose.)
- `docs/adr/` decisions · `docs/scratch-logs/` quick debug logs · `docs/incident-temp/` polished incidents + template · `docs/notes/` study notes
- `terraform/iam/` — IAM root (deployer policy, EC2 app role); planned and `terraform plan` checked, not applied
- `application/product-catalog/` Go service source (copied from the OpenTelemetry demo) · `docker/product-catalog/` Dockerfile, README, `.env.example` · `docker/postgresql/init.sql` · `scripts/product-catalog/` test tooling (`verify_data.py`, venv is gitignored)
- `architecture/` diagrams · `docs/impact/` measured results (`impact-log.md`) + narrative drafts · `kubernetes/ observability/` planned, empty

## How to work with me (learning rules)
- Explain the concept and the "why" BEFORE writing code. Keep it short and concrete.
- I write the core HCL myself where possible; you review, and point out mistakes with the reason.
- After each feature, ask me one comprehension question I could get in an interview.
- When showing `terraform plan`, explain the important lines, not just the summary.
- Prefer showing a small diff over rewriting whole files.
- **Delegation rule.** Routine setup I can do myself (installing tools, running boilerplate or setup scripts, creating standard config): do it, then briefly explain what each step did and why. Before doing it, say which learning-critical part I should do myself and why. Learning-critical = writing the core config/HCL, composing connection strings and env vars, choosing passwords/credentials, reading and diagnosing errors, and any concept I'd be asked in an interview. Never ask for or store my passwords in chat, files or git.

## Safety rules
- Never run `terraform apply` or `destroy` without showing the plan and getting an explicit yes.
- Never commit `.tfstate`, plan files, `.pem` keys, or account IDs. Check `.gitignore` before adding new file types.
- No hardcoded personal IPs in code; use a variable (my ISP IP rotates — see incident #001).
- Remind me about cost and `terraform destroy` at the end of a session (NAT Gateway and EC2 cost money).

## Docs conventions
- Debug in a scratch log (`docs/scratch-logs/sl-NNN.md`, template: `docs/incident-temp/errorlogging-template.md`); promote real incidents to `docs/incident-temp/incident-NNN-*.md`.
- Decisions: `docs/adr/YYYYMMDD-ADR_<topic>.md` — I write the "why", you can tidy the format.
- Keep `architecture/architecture.md` and the README in sync with what is actually deployed.


## Where we are (updated 2026-10-06)
- Sprint: five blocks to Kubernetes (IAM + app, Docker I, Docker II, K8s I, K8s II). Progress is tracked in a private tracker (its link is NOT kept in this public repo).
- App layer: the OpenTelemetry demo. Working on `product-catalog` (Go) with native PostgreSQL 18 on the host (port 5432). A container reaches it via `host.docker.internal`, never `localhost`.
- Done: Block 1 (IAM plan, mental model, architecture v1). Block 2 build: Dockerfile (single-stage, 1.35 GB), container verified serving 10 products, user-defined network test, layer-cache test, volume test, break-it debug (`docs/scratch-logs/sl-003.md`).
- Next: Block 2 settle (blank-page recall + gate), then Block 3 (Compose, multi-stage build to measure the "after" size, ECR).
- Build: from repo root, `docker build -f docker/product-catalog/Dockerfile -t fincomm/product-catalog:dev application/product-catalog`.

## Working notes and gotchas
- Git Bash rewrites `/paths` passed to docker: prefix with `MSYS_NO_PATHCONV=1`. `verify_data.py` must run from `scripts/product-catalog`. Docker Desktop must be running.
- The FinComm repo is the project. Don't default to paths in the demo repo (`opentelemetry-demo`); the demo is only a source to learn from.
- Verify claims before teaching them: run a small test or cite an official doc, and label anything unverified.
- On a failure, paste the actual error and debug it myself before using any AI tool; Claude gives hints after a timebox, not answers.
- Numbers go in `docs/impact/impact-log.md` only if measured; projections must show their assumptions.
