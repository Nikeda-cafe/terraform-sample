# Security Group for Bastion
resource "aws_security_group" "bastion" {
  name        = "${local.prefix}bastion-sg"
  description = "Security group for Bastion EC2 instance"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}bastion-sg"
    }
  )
}

# Outbound rule: Allow MySQL to RDS
resource "aws_security_group_rule" "bastion_to_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = var.rds_security_group_id
  description              = "Allow MySQL to RDS"
}

# Outbound rule: Allow HTTPS for Systems Manager and package updates
resource "aws_security_group_rule" "bastion_https_outbound" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS for Systems Manager and yum updates"
}
