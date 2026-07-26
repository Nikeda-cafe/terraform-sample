locals {
  common_tags = merge(var.tags, {
    Service = "sandbox"
    Scope   = "experiment"
  })

  lambda_source_path = abspath("${path.root}/../../lambda/s3-image-grayscale/dist")
}

module "s3_image_grayscale" {
  source = "../../modules/s3-image-grayscale"

  prefix                = var.prefix
  environment           = var.environment
  tags                  = local.common_tags
  bucket_name_suffix    = var.bucket_name_suffix
  input_prefix          = var.input_prefix
  output_prefix         = var.output_prefix
  lambda_function_name  = var.lambda_function_name
  lambda_runtime        = var.lambda_runtime
  lambda_memory_size    = var.lambda_memory_size
  lambda_timeout        = var.lambda_timeout
  log_retention_in_days = var.log_retention_in_days
  lambda_source_path    = local.lambda_source_path
}
