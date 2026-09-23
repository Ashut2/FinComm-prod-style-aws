# Instance profile role for the app_server EC2 instance
# (terraform/local_state/modules/ec2-instances).
#
# STATUS: the app doesn't call any AWS APIs yet (no S3/CloudWatch code in
# `application/` right now — that folder is still empty). This role is
# therefore intentionally near-empty. Add statements only when the app
# actually needs them, and reference the concrete resource ARN (one
# bucket, one log group) rather than "*".
#
# Trust policy vs permissions policy, made concrete:
#   - assume_role_policy below = "EC2 service is allowed to assume this
#     role" (trust policy)
#   - aws_iam_role_policy below = "what the role can do once assumed"
#     (permissions policy)

resource "aws_iam_role" "ec2_app_role" {
  name = "fincomm-ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_app_profile" {
  name = "fincomm-ec2-app-profile"
  role = aws_iam_role.ec2_app_role.name
}

# Minimal baseline: nothing but the ability to exist. Uncomment / extend
# only when the app needs a specific bucket or log group, e.g.:
#
# resource "aws_iam_role_policy" "ec2_app_logs" {
#   name = "fincomm-ec2-app-logs"
#   role = aws_iam_role.ec2_app_role.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
#       Resource = "arn:aws:logs:ap-south-1:<ACCOUNT_ID>:log-group:/fincomm/app-server:*"
#     }]
#   })
# }
