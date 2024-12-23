terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "trukt-iaac-stage-tf"
    region = "us-east-1"
    key = "stacksync/terraform.tfstate"
    encrypt = true
    dynamodb_table = "terraform-locks-landingzone-stage"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "stage"
      Managed_By  = "terraform"
    }
  }
}

# Data Sources
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["vpc-staging-networking-us-east-1"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "tag:Name"
    values = ["sn-staging-networking-compute-*"]
  }
}

data "aws_subnet" "compute" {
  filter {
    name   = "tag:Name"
    values = ["sn-staging-networking-public-a"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# Module Configurations
module "security" {
  source      = "../../modules/security"
  environment = "stage"
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
  environment       = "stage"
  subnet_ids        = data.aws_subnets.private.ids
  security_group_id = module.security.aurora_security_group_id
  database_name     = "appdb"
  instance_class    = "db.r6g.large"

  depends_on = [module.security]
}

module "compute" {
  source            = "../../modules/compute"
  environment       = "stage"
  subnet_id         = data.aws_subnet.compute.id
  security_group_id = module.security.ec2_security_group_id
  instance_type     = "t3.large"

  depends_on = [module.security]
} 
