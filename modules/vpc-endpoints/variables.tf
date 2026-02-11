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

variable "vpc_name" {
  description = "Name tag of the existing VPC"
  type        = string
}

variable "subnet_tag_names" {
  description = "Name tags of the existing private subnets for Interface endpoints"
  type        = list(string)
}
