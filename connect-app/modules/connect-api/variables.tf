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

variable "connect_instance_id" {
  description = "Amazon Connect instance ID"
  type        = string
}

variable "contact_flow_id" {
  description = "Contact flow ID used for outbound test calls"
  type        = string
}

variable "queue_id" {
  description = "Queue ID used when starting outbound calls"
  type        = string
}

variable "source_phone_number" {
  description = "Optional E.164 source phone number to dial from (defaults to instance's claimed number if omitted)"
  type        = string
  default     = ""
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 15
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
