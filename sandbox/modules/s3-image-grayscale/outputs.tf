output "bucket_name" {
  description = "Name of the S3 bucket receiving source and grayscale images."
  value       = aws_s3_bucket.images.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket receiving source and grayscale images."
  value       = aws_s3_bucket.images.arn
}

output "lambda_function_name" {
  description = "Name of the grayscale Lambda function."
  value       = module.lambda_function.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the grayscale Lambda function."
  value       = module.lambda_function.lambda_function_arn
}

output "input_prefix" {
  description = "Prefix watched for incoming uploads."
  value       = local.input_prefix
}

output "output_prefix" {
  description = "Prefix used for grayscale outputs."
  value       = local.output_prefix
}
