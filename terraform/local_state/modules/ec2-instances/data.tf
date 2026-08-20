data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}


# data block - is purely a read-only API call, it just get asked info back. 

# aws_ami - data source type (comes from provider)
# there are more -> aws_vpc, aws_caller_identity, aws_secretsmanager_secret_version etc
# amazon_linux -> local name ; could be anything you want 
# everything inside {} are query arguments; essentially search filters, not properties you're setting on a real project. most_recent, owners,filter are all inputs to the query


# these arg are totally different for aws_vpc, so registry lookup is important. 

/*
special info about data block


data sources are used constantly for exactly this pattern (finding latest AMIs, referencing shared/pre-existing networking, pulling secrets from AWS Secrets Manager via data "aws_secretsmanager_secret_version", etc.) — but there's a real tradeoff worth knowing: a data source re-queries every single plan/apply. If AWS publishes a new AMI between your last apply and your next one, your next apply could silently pick a different AMI and trigger an instance replacement you didn't explicitly ask for. This is a genuine, debated tradeoff in real teams — dynamic-but-unstable (data lookup) vs pinned-but-stale (hardcoded ID). Some teams pin AMI IDs deliberately and update them via a controlled process instead of always floating to "latest." Worth having opinions about once you're comfortable with the mechanics — not something to solve today.


*/
