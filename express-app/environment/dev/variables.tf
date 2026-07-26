variable "rds_master_password" {
  description = "RDS master password (must match shared/dev で設定した db_master_password)"
  type        = string
  sensitive   = true
}
