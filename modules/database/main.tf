terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "aurora_credentials" {
  name        = "aurora-credentials-${var.environment}-${random_id.suffix.hex}"
  description = "Credentials for Aurora cluster in ${var.environment}"
  
  tags = {
    Environment = var.environment
    Name        = "aurora-credentials-${var.environment}"
  }
}

resource "aws_secretsmanager_secret_version" "aurora_credentials" {
  secret_id = aws_secretsmanager_secret.aurora_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.master.result
    port     = 5432
    database = var.database_name
  })
}

resource "aws_db_subnet_group" "aurora" {
  name        = "aurora-subnet-group-${var.environment}"
  description = "Subnet group for Aurora cluster in ${var.environment}"
  subnet_ids  = var.subnet_ids
  tags = {
    Name        = "aurora-subnet-group-${var.environment}"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

# Aurora cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = "aurora-cluster-${var.environment}"
  engine                = "aurora-postgresql"
  engine_version        = "13.7"
  database_name         = var.database_name
  master_username       = "dbadmin"
  master_password       = jsondecode(aws_secretsmanager_secret_version.aurora_credentials.secret_string)["password"]
  
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [var.security_group_id]
  
  backup_retention_period = var.environment == "prod" ? 7 : 1
  preferred_backup_window = "03:00-04:00"
  
  skip_final_snapshot     = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "aurora-final-snapshot-${var.environment}" : null

  serverlessv2_scaling_configuration {
    min_capacity = var.environment == "prod" ? 1.0 : 0.5
    max_capacity = var.environment == "prod" ? 4.0 : 1.0
  }

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name        = "aurora-cluster-${var.environment}"
    Environment = var.environment
  }
}

# Aurora instances (Writer and Readers)
resource "aws_rds_cluster_instance" "aurora" {
  count               = 1 + var.reader_instance_count  # 1 writer + N readers
  
  identifier          = "aurora-instance-${var.environment}-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = count.index == 0 ? var.instance_class : var.reader_instance_class
  engine              = aws_rds_cluster.aurora.engine
  engine_version      = aws_rds_cluster.aurora.engine_version
  promotion_tier      = count.index
  
  tags = {
    Name        = "aurora-instance-${count.index}-${var.environment}"
    Environment = var.environment
    Role        = count.index == 0 ? "writer" : "reader"
  }
}
