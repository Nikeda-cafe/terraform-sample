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

variable "app_name" {
  description = "Application name for the ECR repository"
  type        = string
  default     = "nextjs-app"
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to keep in the repository"
  type        = number
  default     = 10
}
