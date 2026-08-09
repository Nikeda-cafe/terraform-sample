variable "environment" {
  description = "Environment name"
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

# Amazon Connect 設定
variable "connect_instance_alias" {
  description = "Amazon Connect instance alias (must be globally unique across AWS)"
  type        = string
  default     = "connect-poc-dev"
}

variable "connect_phone_number_country_code" {
  description = "Country code (ISO 3166-1 alpha-2) for the claimed outbound phone number"
  type        = string
  default     = "US"
}

variable "connect_phone_number_type" {
  description = "Phone number type to claim (TOLL_FREE or DID)"
  type        = string
  default     = "DID"
}

variable "connect_recording_bucket_name" {
  description = "S3 bucket name suffix used to store call recordings (prefix is prepended automatically)"
  type        = string
  default     = "connect-poc-call-recordings"
}

# タグ
variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "TerraformProject"
    Environment = "sandbox"
    ManagedBy   = "Terraform"
  }
}
