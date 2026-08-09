output "api_endpoint" {
  description = "Base URL of the outbound call HTTP API"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "outbound_call_path" {
  description = "Full endpoint used to trigger an outbound call"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}outbound-call"
}

output "lambda_function_name" {
  description = "Name of the outbound call Lambda function"
  value       = aws_lambda_function.outbound_call.function_name
}
