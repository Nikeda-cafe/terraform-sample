variable "prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "bucket_name_suffix" {
  description = "Suffix appended to the generated S3 bucket name."
  type        = string
  default     = "image-grayscale"
}

variable "input_prefix" {
  description = "S3 prefix that triggers Lambda execution."
  type        = string
  default     = "uploads/"

  validation {
    condition     = trim(var.input_prefix, "/") != ""
    error_message = "input_prefix must not be empty."
  }
}

variable "output_prefix" {
  description = "S3 prefix where converted grayscale images are written."
  type        = string
  default     = "grayscale/"

  validation {
    condition     = trim(var.output_prefix, "/") != ""
    error_message = "output_prefix must not be empty."
  }
}

variable "lambda_function_name" {
  description = "Base name of the Lambda function."
  type        = string
  default     = "image-grayscale"
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB."
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds."
  type        = number
  default     = 30
}

variable "log_retention_in_days" {
  description = "Retention period for Lambda logs."
  type        = number
  default     = 14
}

variable "lambda_source_path" {
  description = "Absolute path to Lambda source directory or file for packaging."
  type        = string
}
