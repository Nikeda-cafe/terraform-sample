variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "dev-"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_name" {
  description = "Name of the existing VPC"
  type        = string
  default     = "udemy-aws-container-vpc"
}

variable "subnet_tag_names" {
  description = "List of private subnet tag names for DB subnet group"
  type        = list(string)
  default = [
    "udemy-aws-container-subnet-private1-ap-northeast-1a",
    "udemy-aws-container-subnet-private2-ap-northeast-1c",
  ]
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "app"
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "app"
}

variable "db_master_password" {
  description = "Master password for the database (minimum 8 characters)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_master_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

variable "allocated_storage" {
  description = "Allocated storage size in GB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type (gp3, gp2, io1)"
  type        = string
  default     = "gp3"
}

variable "engine_version" {
  description = "MariaDB engine version (major.minor or full version per RDS)"
  type        = string
  default     = "10.11"
}

variable "db_parameter_group_name" {
  description = "DB parameter group (must match MariaDB major version family, e.g. default.mariadb10.11)"
  type        = string
  default     = "default.mariadb10.11"
}

variable "backup_retention_period" {
  description = "Backup retention period (0 = disabled)"
  type        = number
  default     = 0
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Make the DB instance publicly accessible"
  type        = bool
  default     = false
}

variable "allowed_client_security_group_ids" {
  description = "Security group IDs allowed to reach MariaDB on port 3306 (e.g. ECS Fargate task security group)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
