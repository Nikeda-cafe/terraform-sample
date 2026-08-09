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

variable "instance_alias" {
  description = "Amazon Connect instance alias (must be globally unique)"
  type        = string
}

variable "phone_number_country_code" {
  description = "Country code (ISO 3166-1 alpha-2) for the claimed phone number"
  type        = string
  default     = "US"
}

variable "phone_number_type" {
  description = "Phone number type to claim (TOLL_FREE or DID)"
  type        = string
  default     = "DID"
}

variable "phone_number_description" {
  description = "Description for the claimed phone number"
  type        = string
  default     = "Sandbox outbound test number"
}

variable "recording_bucket_name" {
  description = "S3 bucket name used to store call recordings"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
