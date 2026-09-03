output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id

}
