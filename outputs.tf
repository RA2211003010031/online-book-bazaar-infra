output "instance_public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "instance_public_dns" {
  description = "Public DNS names of the EC2 instances"
  value       = aws_instance.web[*].public_dns
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.web_sg.id
}
