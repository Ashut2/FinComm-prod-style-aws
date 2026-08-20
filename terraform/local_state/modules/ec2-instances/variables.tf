variable "region" { 
	description = "AWS region to deploy into"
	type = string
	default = "ap-south-1"
}

# SDK initialised +  endpoint url ec2.temp-demo-error.amazonaws.com - gen by AWS provider

# AWS provider -> plugin which is inside terraform.  this procider does all the talking with actual AWS. 

variable "instance_type" {
	description = "EC2 Instance type"
}


variable "project_name" {
	description = "Name tag prefix for resources"
}
