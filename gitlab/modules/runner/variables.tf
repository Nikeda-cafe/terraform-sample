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
  description = "VPC ID for GitLab Runner EC2"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for GitLab Runner (no public IP)"
  type        = string
}

variable "gitlab_url" {
  description = "GitLab URL used for runner registration (prefer private HTTP URL)"
  type        = string
}

variable "runner_token_ssm_parameter_name" {
  description = "SSM SecureString parameter name holding the runner authentication token (glrt-...)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for GitLab Runner (docker executor)"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 30
}

variable "docker_default_image" {
  description = "Default Docker image for CI jobs"
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
