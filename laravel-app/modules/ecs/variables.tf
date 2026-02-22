variable "env" {
  description = "Environment dev or prod"
  type        = string
  default     = ""
}

variable "prefix" {
  description = "Prefix dev- or prod-"
  type        = string
  default     = ""
}

variable "region" {
  description = "Region"
  type        = string
  default     = "ap-northeast-1"
}

# ECS クラスター
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "laravel-app"
}

variable "vpc_name" {
  description = "Name tag of the existing VPC"
  type        = string
}

variable "task_execution_role_name" {
  description = "Name of the existing ECS task execution IAM role"
  type        = string
  default     = "ecsTaskExecutionRole"
}

variable "task_role_arn" {
  description = "ARN of the IAM role for the task (optional, for DB access etc.)"
  type        = string
  default     = null
}

# タスク定義 - Laravel (app + nginx)
variable "ecr_app_repository_url" {
  description = "ECR repository URL for Laravel app (PHP-FPM) image"
  type        = string
}

variable "ecr_nginx_repository_url" {
  description = "ECR repository URL for Laravel nginx image"
  type        = string
}

variable "container_port" {
  description = "Port on which nginx container listens (ALB target)"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "CPU units for the task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory for the task in MB"
  type        = number
  default     = 1024
}

variable "image_tag" {
  description = "Docker image tag for both app and nginx"
  type        = string
  default     = "latest"
}

variable "laravel_environment" {
  description = "Laravel environment variables (APP_*, DB_*, SESSION_DRIVER, etc.)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

# ECS サービス
variable "subnet_tag_names" {
  description = "Name tags of the existing subnets for ECS tasks"
  type        = list(string)
}

variable "security_group_name" {
  description = "Name tag of the existing security group for ECS tasks"
  type        = string
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

# ALB
variable "enable_load_balancer" {
  description = "Whether to enable Application Load Balancer for ECS service"
  type        = bool
  default     = false
}

variable "alb_subnet_tag_names" {
  description = "Name tags of the existing public subnets for ALB"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS listener"
  type        = string
  default     = ""
}

# Route53
variable "route53_zone_id" {
  description = "Route53 hosted zone ID for creating ALB alias record. Set with route53_record_name to enable."
  type        = string
  default     = ""
}

variable "route53_record_name" {
  description = "Subdomain for the ALB (e.g., laravel for laravel.example.com)"
  type        = string
  default     = ""
}

variable "laravel_app_key_arn" {
    description = "ARN of the Parameter Store parameter for Laravel APP_KEY"
    type        = string
    default     = null
  }
