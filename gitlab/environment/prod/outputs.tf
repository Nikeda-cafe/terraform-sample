output "gitlab_instance_id" {
  description = "GitLab EC2 instance ID (Session Manager target)"
  value       = module.gitlab.instance_id
}

output "gitlab_elastic_ip" {
  description = "GitLab Elastic IP — open in browser for Web UI"
  value       = module.gitlab.elastic_ip
}

output "gitlab_external_url" {
  description = "GitLab external URL"
  value       = module.gitlab.external_url
}

output "gitlab_private_ip" {
  description = "GitLab private IP"
  value       = module.gitlab.instance_private_ip
}

output "session_manager_command" {
  description = "Example AWS CLI command to start a Session Manager shell"
  value       = "aws ssm start-session --target ${module.gitlab.instance_id} --region ap-northeast-1"
}

output "gitlab_runner_instance_id" {
  description = "GitLab Runner EC2 instance ID (Session Manager target)"
  value       = module.runner.instance_id
}

output "gitlab_runner_private_ip" {
  description = "GitLab Runner private IP"
  value       = module.runner.instance_private_ip
}

output "gitlab_runner_token_ssm_parameter" {
  description = "Set glrt-... token here, then run gitlab-runner-register on the runner"
  value       = module.runner.runner_token_ssm_parameter_name
}

output "gitlab_runner_register_command" {
  description = "Run on the runner via Session Manager after updating the SSM token"
  value       = "aws ssm start-session --target ${module.runner.instance_id} --region ap-northeast-1 --document-name AWS-StartInteractiveCommand --parameters command='sudo systemctl start gitlab-runner-register.service'"
}
