# DB Subnet Group for RDS
resource "aws_db_subnet_group" "this" {
  name            = "${local.prefix}rds-db-subnet-group"
  subnet_ids      = data.aws_subnets.this.ids
  description     = "DB subnet group for RDS MySQL"
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}rds-db-subnet-group"
    }
  )
}
