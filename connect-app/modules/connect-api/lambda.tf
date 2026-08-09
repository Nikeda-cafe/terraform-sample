data "aws_caller_identity" "current" {}

data "archive_file" "outbound_call" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/build/outbound_call.zip"
}

resource "aws_iam_role" "outbound_call_lambda" {
  name = "${local.prefix}connect-outbound-call-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "outbound_call_lambda" {
  name = "${local.prefix}connect-outbound-call-lambda-policy"
  role = aws_iam_role.outbound_call_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["connect:StartOutboundVoiceContact"]
        Resource = "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${var.connect_instance_id}/contact/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "outbound_call_lambda_logs" {
  role       = aws_iam_role.outbound_call_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "outbound_call_lambda" {
  name              = "/aws/lambda/${local.prefix}connect-outbound-call"
  retention_in_days = var.log_retention_in_days

  tags = local.common_tags
}

resource "aws_lambda_function" "outbound_call" {
  function_name = "${local.prefix}connect-outbound-call"
  role          = aws_iam_role.outbound_call_lambda.arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = var.lambda_timeout

  filename         = data.archive_file.outbound_call.output_path
  source_code_hash = data.archive_file.outbound_call.output_base64sha256

  environment {
    variables = {
      INSTANCE_ID         = var.connect_instance_id
      CONTACT_FLOW_ID     = var.contact_flow_id
      QUEUE_ID            = var.queue_id
      SOURCE_PHONE_NUMBER = var.source_phone_number
    }
  }

  depends_on = [
    aws_iam_role_policy.outbound_call_lambda,
    aws_iam_role_policy_attachment.outbound_call_lambda_logs,
    aws_cloudwatch_log_group.outbound_call_lambda,
  ]

  tags = local.common_tags
}
