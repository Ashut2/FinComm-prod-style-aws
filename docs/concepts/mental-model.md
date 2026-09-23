# FinComm mental model

FinComm is a house built in layers. Land and roads (network) first, then rooms (compute), then who holds the keys (IAM). Later: furniture (containers), a manager (Kubernetes), a delivery crew (CI/CD) and CCTV (observability). Each layer sits on the one below.

```
 Layer 6  observability/            watch everything (logs, metrics, alarms)   planned
 Layer 5  kubernetes/               run many containers reliably (EKS)         planned
 Layer 4  docker/ + application/    package and write the product              planned
 Layer 3  terraform/ec2_app         compute (EC2 via module)                   built
 Layer 2  terraform/vpc_foundations network                                    built
 Layer 1  terraform/iam + S3 state  identity and Terraform's memory            built
 Always   docs/ + architecture/     why and how, written down
```

## Layer 1: identity and memory
- **S3 bucket `fincomm-tfstate-ashu2026`** is Terraform's memory. Each project has its own state file (its own `key`).
- **`terraform/iam/`** has the deployer policy (what Terraform may do) and the EC2 role + instance profile (what servers may do).
- IAM is a separate project on purpose: destroying the app must never delete the role Terraform runs as (the bootstrap problem, see `terraform/iam/README.md`).
- Theory: `docs/notes/iam-notes.md`.

## Layer 2: network (`vpc_foundations`)
```
Internet -> IGW -> route table (0.0.0.0/0 -> IGW) -> public subnet -> Security Group -> EC2
```
- **VPC** `10.0.0.0/16`: a private slice of AWS.
- **Subnet** `10.0.1.0/24`: "public" only because its route table points to the IGW.
- **IGW**: the door to the internet. **Route table**: the signposts.
- **Security group**: the bouncer (SSH from my IP, HTTP from anywhere).
- **Outputs** (`public_subnet_id`, `app_sg_id`): what this project hands to others.

## Layer 3: compute (`ec2_app`) and how projects link
```
vpc_foundations --outputs--> S3 state --terraform_remote_state--> ec2_app --> module ec2-instances --> EC2
```
- `ec2_app` reads the VPC project's outputs from S3 and passes them into the module (`subnet_id`, `security_group_ids`, `key_name`).
- The module is a reusable function: variables in, `aws_instance` created, outputs returned. The AMI comes from a `data` block (a read-only lookup).
- Incident #001 happened at this seam: `key_name` was declared but never wired through.

## Layers 4-6 (planned)
- `application/` is the product; `docker/` packages it.
- `kubernetes/` (EKS) runs the containers. Nodes go in private subnets, which is why the NAT ADR exists: private nodes need outbound internet without inbound exposure.
- `observability/` adds logs, metrics, alarms. `incidents/` collects post-mortems.

| Future piece | Depends on | Adds to |
|---|---|---|
| Private subnets + NAT | VPC | network layer |
| ALB + HTTPS | public subnets, SG | network layer |
| RDS | private subnets | new Terraform project |
| EKS | private subnets, NAT, IAM roles | new Terraform project |
| CI/CD | Docker image, IAM deployer role | `.github/` |

## Habits that hold it together
1. One Terraform project per concern, linked by outputs and remote state.
2. Decisions go in ADRs, failures in incident logs.
3. Everything is destroyable; destroy after sessions to control cost.

## Self-test
1. Why is a subnet "public"?
2. How does `ec2_app` know which subnet to launch into?
3. Why is IAM a separate Terraform project?
