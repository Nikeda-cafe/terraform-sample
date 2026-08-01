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
  description = "EC2 instance type (GitLab CE recommended: t3.large / 8 GiB RAM or larger)"
  type        = string
  default     = "t3.large"
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

variable "runner_token_ssm_parameter_name" {
  description = "SSM SecureString parameter name holding the runner authentication token (glrt-...)"
  type        = string
}

variable "docker_default_image" {
  description = "Default Docker image for GitLab Runner CI jobs"
  type        = string
  default     = "ruby:3.2"
}

variable "runner_description" {
  description = "GitLab Runner description shown in the UI"
  type        = string
  default     = "prod-aws-docker-runner"
}

variable "runner_tag_list" {
  description = "Comma-separated runner tags"
  type        = string
  default     = "aws,docker"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
