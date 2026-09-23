# FinComm Architecture (v1)

Solid = deployed via Terraform. Dashed = planned (see `docs/adr/20260830-ADR_nat-gateway.md`).

```mermaid
flowchart TB
    user([Internet user])
    me([Me - admin])

    subgraph aws["AWS Region: ap-south-1"]
        s3[("S3: Terraform remote state<br/>fincomm-tfstate-ashu2026")]

        subgraph vpc["VPC 10.0.0.0/16"]
            igw{{Internet Gateway}}
            rt["Public route table<br/>0.0.0.0/0 to IGW"]

            subgraph az["AZ ap-south-1a"]
                subgraph pub["Public subnet 10.0.1.0/24"]
                    sg["Security group fincomm-app-sg<br/>SSH 22 from my /32<br/>HTTP 80 from anywhere"]
                    ec2["EC2 app_server<br/>t3.micro, key fincomm-app-key"]
                    nat["NAT Gateway (planned)"]
                end
                priv["Private subnet (planned)<br/>DB / backend tier"]
            end
        end
    end

    user -- "HTTP 80" --> igw
    me -- "SSH 22" --> igw
    igw --> rt
    rt --> sg
    sg --> ec2
    priv -. "outbound only" .-> nat
    nat -.-> igw

    style nat stroke-dasharray: 5 5
    style priv stroke-dasharray: 5 5
```

## Terraform mapping
| Diagram box | Resource | File |
|---|---|---|
| VPC | `aws_vpc.main` | `terraform/vpc_foundations/main.tf` |
| Public subnet | `aws_subnet.public` | same |
| Internet Gateway | `aws_internet_gateway.main` | same |
| Route table + association | `aws_route_table.public`, `aws_route_table_association.public` | same |
| Security group + rules | `aws_security_group.app_sg` + ingress/egress rules | `security_groups.tf` |
| EC2 | module `ec2-instances` | `terraform/ec2_app/` |
| Remote state | S3 backend; EC2 project reads VPC outputs via `terraform_remote_state` | both projects |

## Two-project flow
`vpc_foundations` applies first and exports `public_subnet_id` and `app_sg_id`. `ec2_app` reads those outputs and launches the EC2 instance into that subnet and SG.
