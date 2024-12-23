output "jumphost_public_ip" {
  description = "Public IP of the jumphost"
  value       = module.compute.public_ip
}

output "jumphost_private_ip" {
  description = "Private IP of the jumphost"
  value       = module.compute.private_ip
}

output "jumphost_ssh_key_arn" {
  description = "ARN of the SSH key secret"
  value       = module.compute.ssh_key_secret_arn
}

output "aurora_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.database.cluster_endpoint
}
