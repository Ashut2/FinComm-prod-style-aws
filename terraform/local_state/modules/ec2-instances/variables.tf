variable "region" { 
	description = "AWS region to deploy into"
	type = string
	default = "ap-south-1"
}

# SDK initialised +  endpoint url ec2.temp-demo-error.amazonaws.com - gen by AWS provider

# AWS provider -> plugin which is inside terraform.  this provider does all the talking with actual AWS. 

variable "instance_type" {
	description = "EC2 Instance type"
}


variable "project_name" {
	description = "Name tag prefix for resources"
}

# Add 2 variables to take input from the root for the security group id & subney id which get attached to the instance


variable "subnet_id" {
  description = "Subnet to launch the instance into"
  type = string

}

variable "security_group_ids" {
  description = "List of security grup ids to attach"

  type = list(string)

}


variable "key_name" {
  description = " SSH key pair name to attach to instance"
  type = string

}




