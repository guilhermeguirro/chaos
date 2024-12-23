variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpn_cidr" {
  description = "VPN CIDR block"
  type        = string
  default     = "10.0.0.0/8"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "ec2_cidr_blocks" {
  type    = list(string)
}

variable "aurora_cidr_blocks" {
  type    = list(string)
}