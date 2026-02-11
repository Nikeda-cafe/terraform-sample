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
  default     = "nextjs-app"
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

# タスク定義
variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "CPU units for the task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory for the task in MB"
  type        = number
  default     = 512
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

# ECS サービス
variable "subnet_tag_name" {
  description = "Name tag of the existing subnets for ECS tasks"
  type        = string
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
