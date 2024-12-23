output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.jumphost.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_eip.jumphost.public_ip
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.jumphost.private_ip
}

output "ssh_key_secret_arn" {
  description = "ARN of the secret containing the SSH key"
  value       = aws_secretsmanager_secret.ec2_ssh_key.arn
}
