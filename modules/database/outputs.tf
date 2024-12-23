output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_rds_cluster.aurora.endpoint
}

output "reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "database_name" {
  description = "The database name"
  value       = var.database_name
}

output "credentials_secret_arn" {
  description = "ARN of the secret containing database credentials"
  value       = aws_secretsmanager_secret.aurora_credentials.arn
}
