terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "devilzinhus3"
    region = "us-east-1"
    key = "stacksync/terraform.tfstate"
    encrypt = true
    dynamodb_table = "devilzinhu_dynamo"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      Managed_By  = "terraform"
    }
  }
}

# Data Sources
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["vpc-dev-networking-us-east-1"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "tag:Name"
    values = ["sn-dev-networking-compute-*"]
  }
}

data "aws_subnet" "compute" {
  filter {
    name   = "tag:Name"
    values = ["sn-dev-networking-public-a"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# Module Configurations
module "security" {
  source      = "../../modules/security"
  environment = "dev"
  vpc_id      = data.aws_vpc.existing.id
  vpc_cidr    = data.aws_vpc.existing.cidr_block
  ec2_cidr_blocks = [
      "34.78.99.183/32", # StackSync
      "34.38.233.8/32", # StackSync
      "35.199.51.43/32", # StackSync
      "34.48.125.38/32", # StackSync
      "10.240.0.0/16", # Acertus
      "192.168.0.0/16", # Acertus
      "10.110.0.0/16", # Acertus
      "10.231.0.0/16" # Trukt-Dev (Azure)
  ]
  aurora_cidr_blocks = [
      "10.240.0.0/16", # Acertus
      "192.168.0.0/16", # Acertus
      "10.110.0.0/16", # Acertus
      "10.231.0.0/16" # Trukt-Dev (Azure)
  ]
}

module "database" {
  source            = "../../modules/database"
  environment       = "dev"
  subnet_ids        = data.aws_subnets.private.ids
  security_group_id = module.security.aurora_security_group_id
  database_name     = "appdb"
  instance_class    = "db.t3.micro"
  
  # Add reader instance configuration
  reader_instance_count = 1  # Number of reader instances you want to create
  reader_instance_class = "db.t3.micro"  # Instance class for reader instances

  depends_on = [module.security]
}

module "compute" {
  source            = "../../modules/compute"
  environment       = "dev"
  subnet_id         = data.aws_subnet.compute.id
  security_group_id = module.security.ec2_security_group_id
  instance_type     = "t2.micro"

  depends_on = [module.security]
} 
