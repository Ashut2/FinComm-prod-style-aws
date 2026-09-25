# main file including terraform, provider & s3 backend block 

terraform {
	required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.58.0"
    }
  }

  backend "s3" {
    bucket = "fincomm-tfstate-ashu2026"
    key = "fincomm/iam/terraform.tfstate"
    region = "ap-south-1"

  }

}

provider "aws" {
  region = "ap-south-1"

}



