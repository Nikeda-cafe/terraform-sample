# Amazon Connect 発信検証（PoC）
module "connect" {
  source = "../../modules/connect"

  environment               = var.environment
  prefix                    = var.prefix
  region                    = var.region
  instance_alias            = var.connect_instance_alias
  phone_number_country_code = var.connect_phone_number_country_code
  phone_number_type         = var.connect_phone_number_type
  recording_bucket_name     = var.connect_recording_bucket_name
  tags                      = var.tags
}

module "connect_api" {
  source = "../../modules/connect-api"

  environment         = var.environment
  prefix              = var.prefix
  region              = var.region
  connect_instance_id = module.connect.instance_id
  contact_flow_id     = module.connect.contact_flow_id
  queue_id            = module.connect.queue_id
  source_phone_number = module.connect.phone_number
  tags                = var.tags
}
