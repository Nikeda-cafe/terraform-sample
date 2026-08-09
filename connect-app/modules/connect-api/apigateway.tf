# 外部システムから発信をトリガーするための HTTP API（POST /outbound-call）
resource "aws_apigatewayv2_api" "outbound_call" {
  name          = "${local.prefix}connect-outbound-call-api"
  protocol_type = "HTTP"

  tags = local.common_tags
}

resource "aws_apigatewayv2_integration" "outbound_call" {
  api_id                 = aws_apigatewayv2_api.outbound_call.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.outbound_call.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "outbound_call" {
  api_id    = aws_apigatewayv2_api.outbound_call.id
  route_key = "POST /outbound-call"
  target    = "integrations/${aws_apigatewayv2_integration.outbound_call.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.outbound_call.id
  name        = "$default"
  auto_deploy = true

  tags = local.common_tags
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.outbound_call.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.outbound_call.execution_arn}/*/*"
}
