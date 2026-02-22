output "primary_endpoint_address" {
  description = "Address of the primary node endpoint for Laravel REDIS_HOST"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Address of the reader node endpoint (for read replicas)"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Port number for Redis/Valkey connections"
  value       = aws_elasticache_replication_group.this.port
}
