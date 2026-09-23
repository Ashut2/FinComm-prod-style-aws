# FinComm — production-style AWS project

A learning project. The owner must be able to explain every concept and resource to anyone, and will record a demo video. Optimise for **understanding first, speed second**.

## Layout
- `terraform/vpc_foundations/` — network layer (VPC, public subnet, IGW, route table, security groups). State: S3 `fincomm-tfstate-ashu2026`, region `ap-south-1`.
- `terraform/ec2_app/` — EC2 root module calling `modules/ec2-instances`; reads VPC outputs via `terraform_remote_state`. (Renamed from `local_state`; its S3 state key is still `fincomm/local_state/terraform.tfstate` on purpose.)
- `docs/adr/` decisions · `docs/scratch-logs/` quick debug logs · `docs/incident-temp/` polished incidents + template · `docs/notes/` study notes
- `architecture/` diagrams · `application/ docker/ kubernetes/ observability/` planned, empty

## How to work with me (learning rules)
- Explain the concept and the "why" BEFORE writing code. Keep it short and concrete.
- I write the core HCL myself where possible; you review, and point out mistakes with the reason.
- After each feature, ask me one comprehension question I could get in an interview.
- When showing `terraform plan`, explain the important lines, not just the summary.
- Prefer showing a small diff over rewriting whole files.

## Safety rules
- Never run `terraform apply` or `destroy` without showing the plan and getting an explicit yes.
- Never commit `.tfstate`, plan files, `.pem` keys, or account IDs. Check `.gitignore` before adding new file types.
- No hardcoded personal IPs in code; use a variable (my ISP IP rotates — see incident #001).
- Remind me about cost and `terraform destroy` at the end of a session (NAT Gateway and EC2 cost money).

## Docs conventions
- Debug in a scratch log (`docs/scratch-logs/sl-NNN.md`, template: `docs/incident-temp/errorlogging-template.md`); promote real incidents to `docs/incident-temp/incident-NNN-*.md`.
- Decisions: `docs/adr/YYYYMMDD-ADR_<topic>.md` — I write the "why", you can tidy the format.
- Keep `architecture/architecture.md` and the README in sync with what is actually deployed.
