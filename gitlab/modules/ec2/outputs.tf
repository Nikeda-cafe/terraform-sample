output "instance_id" {
  description = "GitLab EC2 instance ID"
  value       = aws_instance.gitlab.id
}

output "instance_private_ip" {
  description = "GitLab private IP address"
  value       = aws_instance.gitlab.private_ip
}

output "elastic_ip" {
  description = "GitLab Elastic IP address"
  value       = aws_eip.gitlab.public_ip
}

output "external_url" {
  description = "GitLab external URL configured at install time"
  value       = local.external_url
}

output "security_group_id" {
  description = "GitLab security group ID"
  value       = aws_security_group.gitlab.id
}

output "iam_role_name" {
  description = "GitLab EC2 IAM role name"
  value       = aws_iam_role.gitlab.name
}
