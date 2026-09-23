# Quiz: FinComm mental model (2026-09-23)

Self-test from `docs/concepts/mental-model.md`. Each entry has my answer, what to fix, and a polished version I can say out loud.

## Q1. "I created a subnet, so it's public." What is missing?

**My answer:** A subnet is not public or private just because it exists. It becomes public when its route table has a rule pointing to an internet gateway. With no such route it is private.

**Verdict:** Correct in substance.

**Fixes / additions**
- The route lives in the *route table*, and the *association* links the subnet to that table. Both are needed (`aws_route_table` + `aws_route_table_association`).
- A subnet with no explicit association falls back to the VPC's main route table, so "no route = private" is right.
- The subnet also needs the IGW attached to the VPC, and instances need a public IP (`map_public_ip_on_launch = true`) to be reachable.

**Polished:** "A subnet is public only if its route table sends `0.0.0.0/0` to an internet gateway and the subnet is associated with that table. Without that route it is private, whatever I call it."

## Q2. Where does `subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_id` come from?

**My answer:** A data block looks up values from the vpc_foundations project, which outputs the subnet ID and SG ID. The module then uses them.

**Verdict:** Right idea, two corrections.

**Fixes**
- It does not read the *folder*. It reads the vpc_foundations **state file in S3** (`fincomm/vpc_foundations/terraform.tfstate`), and only the values declared as `output` blocks.
- The reference syntax is `data.terraform_remote_state.<local_name>.outputs.<output_name>`. Here: `data.terraform_remote_state.vpc.outputs.public_subnet_id`.
- Order matters: vpc_foundations must be applied first, or the outputs don't exist yet.

**Polished:** "`outputs.tf` in vpc_foundations exports the IDs. After `apply` they are saved in that project's state file in S3. `ec2_app` has a `terraform_remote_state` data block pointing at that S3 key, reads the outputs, and passes them into the EC2 module."

## Q3. Why is IAM a separate Terraform project?

**My answer:** So their state doesn't overlap. If combined, `terraform destroy` from the root would also destroy the roles and permissions.

**Verdict:** The destroy risk is the right core. The "state overlap" wording is vague and "the root" is misleading.

**Fixes**
- There is no single root here. Each folder is its own root module with its own state.
- The precise reasons: (1) **blast radius**, destroying the app or network must not delete the role Terraform runs as; (2) **different lifecycle**, IAM changes rarely, the app changes often; (3) **bootstrap**, something must exist first with permission to create the deployer role.

**Polished:** "IAM has its own state and lifecycle so that destroying or breaking the app or network project can never delete the identity Terraform is using to run. It also limits the blast radius of mistakes."

## Bonus. Incident #001: why did the second cause only show up after the first was fixed?

**My answer:** I didn't know.

**Explanation:** An SSH login has stages, like a door and then a lock.
1. **Reachability:** can my packets get to port 22? This needed the security group to allow my current IP. My IP had changed, so the connection timed out at the door.
2. **Authentication:** once connected, does the server accept my key? The instance had `key_name = null`, so no key was installed and the server said `Permission denied (publickey)`.

Stage 1 failing hides stage 2, because you can't be rejected at the lock if you never reach the door. Fixing the IP let me reach stage 2, which exposed the missing key. The two errors also look different: a timeout means "blocked or unreachable", while "Permission denied" means "reached, but refused". That difference tells you which stage failed.

**Polished:** "There were two independent failures at two stages of SSH: network reachability, then key authentication. The first masked the second, and the error message changing from timeout to permission denied showed I had moved to the next stage."
