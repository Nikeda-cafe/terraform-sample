# Security Group for RDS MySQL
resource "aws_security_group" "rds" {
  name        = "${local.prefix}rds-sg"
  description = "Security group for RDS MySQL database"
  vpc_id      = data.aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}rds-sg"
    }
  )
}

# Allow MySQL inbound from Bastion security group
resource "aws_security_group_rule" "rds_inbound" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.bastion_security_group_id
  description              = "Allow MySQL from Bastion"
}

# Allow all outbound traffic
resource "aws_security_group_rule" "rds_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}
