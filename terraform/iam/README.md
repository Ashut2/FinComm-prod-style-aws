# Why this folder is separate from vpc_foundations / ec2-instances

Bootstrapping problem (worth knowing for interviews): Terraform can't create
the very IAM identity it needs in order to run. Something has to exist first
with enough permission to create that deployer role — normally a human,
using their own admin/break-glass login, one time, by hand or via a
separate "bootstrap" apply. After that, day-to-day `terraform apply` runs
using the scoped deployer role below, not the human's admin credentials.

Keeping IAM in its own Terraform root (separate state file) is deliberate:
if you ever need to roll back or destroy the app/VPC state, you don't want
that same `terraform destroy` able to also delete the IAM role it's
running as.
