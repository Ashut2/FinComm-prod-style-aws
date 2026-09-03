# This is root module which will call the child module -> module / ec2-instances

terraform {
  required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "6.58.0"
      }
  }

  backend "s3" {
     bucket = "fincomm-tfstate-ashu2026"
     key = "fincomm/local_state/terraform.tfstate"
     region = "ap-south-1"
  }

}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
      bucket = "fincomm-tfstate-ashu2026"
      key = "fincomm/vpc_foundations/terraform.tfstate"
      region = "ap-south-1"
  }

}

provider "aws" {
	region = "ap-south-1"
}


module "ec2-instances" {
	
	source = "./modules/ec2-instances"

  instance_type = "t3.micro"

  project_name = "module-created-ec2" 

  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_id
  security_group_ids = [data.terraform_remote_state.vpc.outputs.app_sg_id]

  key_name = "fincomm-app-key"
}

################### My Confusions related to data terraform remote backend block #########################

# Pulls values from vpc_foundations' *already-applied* remote state (S3),
# via its `output` blocks -> not reading files/folders on disk.
# data.terraform_remote_state.<name>.outputs.<exact-output-name-from-that-project>
# subnet_id           = data.terraform_remote_state.vpc.outputs.public_subnet_id
# security_group_ids  = [data.terraform_remote_state.vpc.outputs.app_sg_id]

##########################################################################################################
