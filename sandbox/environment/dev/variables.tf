variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "sandbox-"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "tags" {
  description = "Common tags to apply to sandbox resources"
  type        = map(string)
  default = {
    Project     = "TerraformProject"
    Environment = "sandbox"
    ManagedBy   = "Terraform"
  }
}

variable "bucket_name_suffix" {
  description = "Suffix appended to the generated S3 bucket name."
  type        = string
  default     = "image-grayscale"
}

variable "input_prefix" {
  description = "Prefix watched for uploaded source images."
  type        = string
  default     = "uploads/"
}

variable "output_prefix" {
  description = "Prefix where grayscale images are written."
  type        = string
  default     = "grayscale/"
}

variable "lambda_function_name" {
  description = "Base name for the image grayscale Lambda function."
  type        = string
  default     = "image-grayscale"
}

variable "lambda_runtime" {
  description = "Runtime for the image grayscale Lambda function."
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_memory_size" {
  description = "Memory size for the image grayscale Lambda function."
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Timeout for the image grayscale Lambda function."
  type        = number
  default     = 30
}

variable "log_retention_in_days" {
  description = "CloudWatch Logs retention period for the image grayscale Lambda function."
  type        = number
  default     = 14
}
