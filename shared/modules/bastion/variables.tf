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

variable "vpc_id" {
  description = "VPC ID for Bastion deployment"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for Bastion instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "rds_security_group_id" {
  description = "RDS security group ID for outbound access"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
