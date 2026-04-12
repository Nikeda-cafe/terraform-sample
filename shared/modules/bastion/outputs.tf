# Bastion outputs
output "instance_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
}

output "instance_private_ip" {
  description = "Bastion private IP address"
  value       = aws_instance.bastion.private_ip
}

output "instance_public_ip" {
  description = "Bastion public IP address"
  value       = aws_instance.bastion.public_ip
}

output "security_group_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion.id
}

output "security_group_name" {
  description = "Bastion security group name"
  value       = aws_security_group.bastion.name
}

output "iam_role_name" {
  description = "Bastion IAM role name"
  value       = aws_iam_role.bastion.name
}

output "iam_instance_profile_name" {
  description = "Bastion IAM instance profile name"
  value       = aws_iam_instance_profile.bastion.name
}
