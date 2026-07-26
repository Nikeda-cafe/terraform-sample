# RDS MariaDB Database Instance
resource "aws_db_instance" "this" {
  identifier        = "${local.prefix}mariadb-db"
  engine            = "mariadb"
  engine_version    = var.engine_version
  instance_class    = "db.t3.micro"
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = true

  # Database configuration
  db_name  = var.db_name
  username = var.db_master_username
  password = var.db_master_password
  port     = 3306

  # Subnet and security
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = var.publicly_accessible

  # Backup and maintenance
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  skip_final_snapshot     = var.skip_final_snapshot
  copy_tags_to_snapshot   = false

  # High availability
  multi_az = var.multi_az

  # Updates and monitoring
  auto_minor_version_upgrade = true
  parameter_group_name       = var.db_parameter_group_name

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}mariadb-db"
    }
  )

  depends_on = [aws_security_group.rds]
}
