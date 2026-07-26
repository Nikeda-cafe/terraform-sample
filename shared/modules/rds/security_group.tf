# Security Group for RDS MariaDB (MySQL protocol / port 3306)
resource "aws_security_group" "rds" {
  name        = "${local.prefix}rds-sg"
  description = "Security group for RDS MariaDB database"
  vpc_id      = data.aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}rds-sg"
    }
  )
}

# Allow MariaDB from application tasks (e.g. ECS)
resource "aws_security_group_rule" "rds_inbound_clients" {
  for_each = toset(var.allowed_client_security_group_ids)

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = each.value
  description              = "Allow MariaDB (3306) from application security group"
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
