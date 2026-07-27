variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_id" {
  description = "VPC ID for GitLab EC2"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for GitLab instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (GitLab CE minimum: t3.medium, 4 GiB RAM)"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 50
}

variable "external_url" {
  description = "GitLab external URL; defaults to http://<Elastic IP> when null"
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
