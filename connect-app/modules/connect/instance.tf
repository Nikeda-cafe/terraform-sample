# Amazon Connect インスタンス（CONNECT_MANAGED による認証、PoC 用の最小構成）
resource "aws_connect_instance" "this" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  outbound_calls_enabled   = true
  instance_alias           = "${local.prefix}${var.instance_alias}"

  tags = local.common_tags
}
