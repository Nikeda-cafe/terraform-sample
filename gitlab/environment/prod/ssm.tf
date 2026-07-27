resource "aws_ssm_parameter" "runner_authentication_token" {
  name        = "/prod/gitlab/runner-authentication-token"
  description = "GitLab runner authentication token (glrt-...) from Admin > CI/CD > Runners"
  type        = "SecureString"
  value       = "unset"

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Service     = "gitlab"
  }

  lifecycle {
    ignore_changes = [value]
  }
}
