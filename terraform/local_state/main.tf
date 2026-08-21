# This is root module which will call the chile module -> module / ec2-instances

terraform {
  required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "6.58.0"
      }
  }

  backend "s3" {
     bucket = "fincomm-tfstate-ashu2026"
     key = "fincomm/ocal_state/terraform.tfstate"
     region = "ap-south-1"
  }

}

provider "aws" {
	region = "ap-south-1"
}

module "ec2-instances" {
	
	source = "./modules/ec2-instances"

  instance_type = "t2.micro"

  project_name = "module-created-ec2" 
}
