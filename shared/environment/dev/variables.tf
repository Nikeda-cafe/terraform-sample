variable "environment" {
  description = "Environment name"
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

# RDS Configuration
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "app"
}

variable "db_master_username" {
  description = "RDS master username"
  type        = string
  default     = "app"
}

variable "db_master_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "RDS storage type"
  type        = string
  default     = "gp3"
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "backup_retention_period" {
  description = "RDS backup retention period"
  type        = number
  default     = 0
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on RDS deletion"
  type        = bool
  default     = true
}

# EC2 Bastion Configuration
variable "bastion_instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Tags
variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "TerraformProject"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
