variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Aurora DB subnet group"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for Aurora cluster"
  type        = string
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
}

variable "instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
}

variable "create_read_replica" {
  description = "Whether to create a read replica"
  type        = bool
  default     = false
}

variable "read_replica_instance_class" {
  description = "Instance class for the read replica"
  type        = string
  default     = null
}

variable "read_replica_count" {
  description = "Number of read replicas to create"
  type        = number
  default     = 0
}

variable "reader_instance_count" {
  description = "Number of reader instances to create in the Aurora cluster"
  type        = number
  default     = 0
}

variable "reader_instance_class" {
  description = "Instance class for reader instances"
  type        = string
  default     = null
}
