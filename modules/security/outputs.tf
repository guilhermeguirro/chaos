output "aurora_security_group_id" {
  description = "ID do security group do Aurora"
  value       = aws_security_group.aurora.id
}

output "ec2_security_group_id" {
  description = "ID do security group do EC2"
  value       = aws_security_group.ec2.id
}
