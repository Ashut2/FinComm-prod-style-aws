# This is root module which will call the chile module -> module / ec2-instances


provider "aws" {
	region = "ap-south-1"

}

module "ec2-instances" {
	
	source = "./modules/ec2-instances"

  instance_type = "t2.micro"

  project_name = "module-created-ec2" 
}
