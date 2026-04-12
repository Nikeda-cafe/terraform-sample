output "vpc_endpoint_ids" {
  description = "IDs of the created VPC endpoints"
  value       = module.vpc_endpoints.vpc_endpoint_ids
}

# RDS outputs
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_address" {
  description = "RDS host address"
  value       = module.rds.rds_address
}

output "rds_port" {
  description = "RDS port"
  value       = module.rds.rds_port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.rds_database_name
}

output "rds_master_username" {
  description = "RDS master username"
  value       = module.rds.rds_master_username
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.rds.rds_security_group_id
}

# Bastion outputs
output "bastion_instance_id" {
  description = "Bastion instance ID"
  value       = module.bastion.instance_id
}

output "bastion_private_ip" {
  description = "Bastion private IP address"
  value       = module.bastion.instance_private_ip
}

output "bastion_public_ip" {
  description = "Bastion public IP address"
  value       = module.bastion.instance_public_ip
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = module.bastion.security_group_id
}

output "bastion_iam_role_name" {
  description = "Bastion IAM role name"
  value       = module.bastion.iam_role_name
}

# Connection command
output "bastion_connection_command" {
  description = "AWS CLI command to connect to Bastion"
  value       = "aws ssm start-session --target ${module.bastion.instance_id}"
}

output "rds_connection_info" {
  description = "RDS connection information"
  value = {
    endpoint = module.rds.rds_endpoint
    database = module.rds.rds_database_name
    username = module.rds.rds_master_username
    port     = module.rds.rds_port
  }
}
