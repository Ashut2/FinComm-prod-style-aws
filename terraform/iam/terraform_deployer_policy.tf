# Least-privilege policy for the identity that RUNS `terraform apply` for
# this repo (currently: Ashu's own CLI credentials; later: a CI role).
#
# Scoped to exactly what this repo's two roots manage today:
#   - terraform/vpc_foundations  -> VPC, subnet, IGW, route table, SGs
#   - terraform/local_state      -> one EC2 instance
#   - both roots' remote state, which lives in one S3 bucket
#
# NOT included: anything for CI/OIDC or Kubernetes/EKS — those don't exist
# in this repo yet. Writing IAM permissions for resources you haven't
# built yet is itself a least-privilege violation (unused permissions are
# attack surface with zero benefit). Add a new statement when that
# infrastructure is actually created, not before.

data "aws_iam_policy_document" "terraform_deployer" {

  # --- Terraform remote state: read/write state file + lock ---
  statement {
    sid    = "TFStateBucketObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::fincomm-tfstate-ashu2026/fincomm/*",
    ]
  }

  statement {
    sid    = "TFStateBucketList"
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::fincomm-tfstate-ashu2026"]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["fincomm/*"]
    }
  }

  # NOTE: no dynamodb:* statement here. Confirm whether this backend uses
  # a DynamoDB lock table or the newer S3-native locking (`use_lockfile`)
  # before you assume one isn't needed — I have NOT verified this from
  # the backend block, it simply isn't declared there yet.

  # --- Networking (vpc_foundations root) ---
  statement {
    sid    = "NetworkingReadWrite"
    effect = "Allow"
    actions = [
      "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:DescribeVpcs", "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:DescribeSubnets", "ec2:ModifySubnetAttribute",
      "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:DescribeInternetGateways",
      "ec2:AttachInternetGateway", "ec2:DetachInternetGateway",
      "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:DescribeRouteTables",
      "ec2:CreateRoute", "ec2:DeleteRoute",
      "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable",
      "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateTags", "ec2:DeleteTags", "ec2:DescribeTags",
    ]
    resources = ["*"]
    # Left as "*" because EC2 networking API calls (Create*) don't support
    # resource-level restriction before the resource exists — this is a
    # documented AWS limitation, not a shortcut. Tighten with a
    # aws:RequestTag / ResourceTag condition once everything here is
    # consistently tagged (e.g. Project=fincomm), which narrows it to
    # "only touch things tagged fincomm" even though the ARN stays "*".
  }

  # --- Compute (local_state / ec2-instances module) ---
  statement {
    sid    = "EC2InstanceLifecycle"
    effect = "Allow"
    actions = [
      "ec2:RunInstances", "ec2:TerminateInstances", "ec2:StopInstances", "ec2:StartInstances",
      "ec2:DescribeInstances", "ec2:DescribeInstanceAttribute",
      "ec2:DescribeImages",       # needed for the data.aws_ami lookup
      "ec2:DescribeKeyPairs",
    ]
    resources = ["*"]  # same RunInstances resource-level limitation as above
  }

  # --- Letting Terraform attach the EC2 instance role below ---
  statement {
    sid    = "PassEC2AppRoleOnly"
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = ["arn:aws:iam::*:role/fincomm-ec2-app-role"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "terraform_deployer" {
  name   = "fincomm-terraform-deployer"
  policy = data.aws_iam_policy_document.terraform_deployer.json
}
