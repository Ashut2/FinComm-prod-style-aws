terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.58.0"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.security_group_ids # Security group are very different from vpc security group. security_groups is meant for non-VPC or default-VPC name-based assignments and can cause recreation loops.
  
  key_name = var.key_name # I forgot this line & this led me to waste of 5 hours of debugging on all possible causes that I thought might be the case. more explicit info in incident-001-look at /docs/incident-temp of this repo. 

  tags = {
    Name = "${var.project_name}-app-server"
  }
}

