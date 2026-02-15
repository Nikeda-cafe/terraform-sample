output "vpc_endpoint_ids" {
  description = "IDs of the created VPC endpoints"
  value       = module.vpc_endpoints.vpc_endpoint_ids
}
