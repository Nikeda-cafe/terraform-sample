# アウトバウンドのテスト発信用に電話番号を割り当てる（Connect が発信する際の発信元番号）
resource "aws_connect_phone_number" "outbound" {
  target_arn   = aws_connect_instance.this.arn
  country_code = var.phone_number_country_code
  type         = var.phone_number_type
  description  = var.phone_number_description

  tags = local.common_tags
}
