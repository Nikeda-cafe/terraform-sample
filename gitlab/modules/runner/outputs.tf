output "instance_id" {
  description = "GitLab Runner EC2 instance ID"
  value       = aws_instance.runner.id
}

output "instance_private_ip" {
  description = "GitLab Runner private IP address"
  value       = aws_instance.runner.private_ip
}

output "security_group_id" {
  description = "GitLab Runner security group ID"
  value       = aws_security_group.runner.id
}

output "runner_token_ssm_parameter_name" {
  description = "SSM parameter name for the runner authentication token"
  value       = var.runner_token_ssm_parameter_name
}
