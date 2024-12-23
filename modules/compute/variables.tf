variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for EC2"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
