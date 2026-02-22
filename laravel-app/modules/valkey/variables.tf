variable "prefix" {
  description = "Prefix for resource names (e.g., dev-, prod-)"
  type        = string
}

variable "env" {
  description = "Environment (dev or prod)"
  type        = string
}

variable "vpc_name" {
  description = "Name tag of the existing VPC"
  type        = string
}

variable "subnet_tag_names" {
  description = "Name tags of the private subnets for ElastiCache"
  type        = list(string)
}

variable "ecs_security_group_name" {
  description = "Name of the ECS task security group (to allow inbound on 6379)"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node type (e.g., cache.t4g.micro for dev, cache.t4g.small for prod)"
  type        = string
  default     = "cache.t4g.micro"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (primary + replicas)"
  type        = number
  default     = 1
}

variable "multi_az_enabled" {
  description = "Whether to enable Multi-AZ"
  type        = bool
  default     = false
}

variable "automatic_failover_enabled" {
  description = "Whether to enable automatic failover"
  type        = bool
  default     = false
}
