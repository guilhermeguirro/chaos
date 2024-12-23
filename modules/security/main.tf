resource "aws_security_group" "ec2" {
  name_prefix = "ec2-sg-jumpbox-"
  vpc_id      = var.vpc_id
  description = "Security group for EC2 jumphost"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ec2_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "ec2-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "aurora" {
  name_prefix = "aurora-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for Aurora"

  # Allow access from EC2 security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
    description     = "Access from EC2 instances"
  }

  # PostgreSQL
  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.aurora_cidr_blocks
  }


  tags = {
    Name        = "aurora-sg-${var.environment}"
    Environment = var.environment
  }
}
