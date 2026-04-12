# RDS outputs
output "rds_endpoint" {
  description = "RDS endpoint (address:port)"
  value       = aws_db_instance.this.endpoint
}

output "rds_address" {
  description = "RDS instance address"
  value       = aws_db_instance.this.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.this.port
}

output "rds_database_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "rds_master_username" {
  description = "The master username for the database"
  value       = aws_db_instance.this.username
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}

output "rds_security_group_name" {
  description = "RDS Security Group name"
  value       = aws_security_group.rds.name
}

output "db_subnet_group_name" {
  description = "DB Subnet Group name"
  value       = aws_db_subnet_group.this.name
}

output "db_instance_id" {
  description = "RDS DB Instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_resource_id" {
  description = "RDS DB Instance resource ID"
  value       = aws_db_instance.this.resource_id
}
