terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.30.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  input_prefix_trimmed  = trim(var.input_prefix, "/")
  output_prefix_trimmed = trim(var.output_prefix, "/")

  input_prefix  = "${local.input_prefix_trimmed}/"
  output_prefix = "${local.output_prefix_trimmed}/"

  bucket_name = lower(join("-", compact([
    trim(var.prefix, "-"),
    var.bucket_name_suffix,
    data.aws_caller_identity.current.account_id,
  ])))

  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "s3-image-grayscale"
  })
}

resource "aws_s3_bucket" "images" {
  bucket = local.bucket_name

  tags = merge(local.common_tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${trim(var.prefix, "-")}-${var.lambda_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "AllowBucketReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.images.arn}/*"]
  }
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${trim(var.prefix, "-")}-${var.lambda_function_name}-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${trim(var.prefix, "-")}-${var.lambda_function_name}"
  retention_in_days = var.log_retention_in_days

  tags = local.common_tags
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.8"

  function_name = "${trim(var.prefix, "-")}-${var.lambda_function_name}"
  description   = "Converts uploaded images to grayscale."
  handler       = "index.handler"
  runtime       = var.lambda_runtime
  source_path   = var.lambda_source_path

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  create_role = false
  lambda_role = aws_iam_role.lambda.arn

  cloudwatch_logs_retention_in_days = var.log_retention_in_days
  use_existing_cloudwatch_log_group = true

  environment_variables = {
    SOURCE_BUCKET_NAME = aws_s3_bucket.images.bucket
    INPUT_PREFIX       = local.input_prefix
    OUTPUT_PREFIX      = local.output_prefix
  }

  tags = local.common_tags

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy.lambda,
  ]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.images.arn
}

resource "aws_s3_bucket_notification" "images" {
  bucket = aws_s3_bucket.images.id

  lambda_function {
    lambda_function_arn = module.lambda_function.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = local.input_prefix
  }

  lifecycle {
    precondition {
      condition     = local.input_prefix != local.output_prefix
      error_message = "output_prefix must be different from input_prefix."
    }
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
