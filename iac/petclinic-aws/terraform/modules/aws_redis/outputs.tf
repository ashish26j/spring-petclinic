output "primary_endpoint" {
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
  description = "Primary endpoint for writes"
}

output "reader_endpoint" {
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
  description = "Reader endpoint for reads"
}

output "port" {
  value       = aws_elasticache_replication_group.this.port
  description = "Redis port"
}