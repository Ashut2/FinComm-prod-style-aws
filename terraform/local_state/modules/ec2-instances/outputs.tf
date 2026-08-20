output "instance_id" {

	description = "ID of the EC2 instance"
	value = aws_instance.app_server.id

}

output "public_ip" {
	description = "Public IP of the EC2 Instance"
	value = aws_instance.app_server.public_ip

}

output "ec2_instance_status" {

	description = "The current power and operational state of the EC2 Instance"

	value = aws_instance.app_server.instance_state
}
