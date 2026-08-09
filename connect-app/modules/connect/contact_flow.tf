# アウトバウンド用コンタクトフロー：通話の録音を開始し、テストメッセージを再生した後に切断する
# StartOutboundVoiceContact 実行時の ContactFlowId として使用する
resource "aws_connect_contact_flow" "outbound_test" {
  instance_id = aws_connect_instance.this.id
  name        = "${local.prefix}outbound-test-flow"
  description = "Sandbox PoC: records the call, plays a test message, then disconnects"
  type        = "CONTACT_FLOW"
  content     = file("${path.module}/contact_flow.json")

  tags = local.common_tags
}
