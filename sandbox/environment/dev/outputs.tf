output "sandbox_environment" {
  description = "Sandbox environment name"
  value       = var.environment
}

output "sandbox_prefix" {
  description = "Prefix used for sandbox resources"
  value       = var.prefix
}

output "sandbox_region" {
  description = "AWS region used by sandbox"
  value       = var.region
}

output "sandbox_tags" {
  description = "Default tags applied to sandbox resources"
  value       = local.common_tags
}

output "image_bucket_name" {
  description = "S3 bucket used for source and grayscale images."
  value       = module.s3_image_grayscale.bucket_name
}

output "image_bucket_arn" {
  description = "ARN of the S3 bucket used for source and grayscale images."
  value       = module.s3_image_grayscale.bucket_arn
}

output "image_grayscale_lambda_name" {
  description = "Lambda function that converts uploaded images to grayscale."
  value       = module.s3_image_grayscale.lambda_function_name
}

output "image_grayscale_lambda_arn" {
  description = "ARN of the Lambda function that converts uploaded images to grayscale."
  value       = module.s3_image_grayscale.lambda_function_arn
}

output "image_upload_prefix" {
  description = "S3 prefix watched for uploaded source images."
  value       = module.s3_image_grayscale.input_prefix
}

output "image_grayscale_prefix" {
  description = "S3 prefix where grayscale images are written."
  value       = module.s3_image_grayscale.output_prefix
}
