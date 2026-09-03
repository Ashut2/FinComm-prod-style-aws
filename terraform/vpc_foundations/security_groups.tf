# this is the terraform file containing HCL to provision security groups rules for the vpc.

# Questions I needed to answer first -> 

# A SG need to attach to something ; It has to attached to that VPC though vpc_id 

# Which vpc it belongs to ? how would i reference aws_vpc.main.id here ?


# We use data.tf to look up to data which are not created inside this terraform provisioning like fetching up AWS-AMI. but to reference the vpc we can  do it directly as terraform process all .tf files togethor. so to reference vpc id, I can directly use aws_vpc.main.id in security_group.tf 

# In terraform resgitry example they used allow_tls rule for 443_port and referenced the vpc_cidr_block cause it solves the different problem . it is used to let different tiers sitting in different subnets communicate with each other within the same vpc; e.g web tier communicating with logical-backend tier or backend tier communicating with database tier.  


# to understand above example, first read about three-tier-architecture article.  

#########################################################

resource "aws_security_group" "app_sg" {
  name        = "fincomm-app-sg"
  description = "Allow ssh from my IP and HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "fincomm-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_me" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "157.49.46.196/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_from_anywhere" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


