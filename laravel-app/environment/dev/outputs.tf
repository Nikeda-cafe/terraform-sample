output "ecr_app_repository_url" {
  description = "The URL of the Laravel app ECR repository"
  value       = data.aws_ecr_repository.laravel_app.repository_url
}

output "ecr_nginx_repository_url" {
  description = "The URL of the Laravel nginx ECR repository"
  value       = data.aws_ecr_repository.laravel_nginx.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "alb_dns_name" {
  description = "ALB DNS name for HTTPS access"
  value       = module.ecs.alb_dns_name
}
