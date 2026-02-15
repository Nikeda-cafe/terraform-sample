output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = data.aws_security_group.this.id
}

output "task_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = data.aws_iam_role.task_execution.arn
}

output "alb_dns_name" {
  description = "ALB DNS name for HTTPS access"
  value       = var.enable_load_balancer ? aws_lb.this[0].dns_name : null
}

output "alb_zone_id" {
  description = "ALB Route 53 zone ID for Alias records"
  value       = var.enable_load_balancer ? aws_lb.this[0].zone_id : null
}

output "alb_arn" {
  description = "ALB ARN"
  value       = var.enable_load_balancer ? aws_lb.this[0].arn : null
}
