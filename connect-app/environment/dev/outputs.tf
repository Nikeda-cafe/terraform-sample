output "connect_instance_id" {
  description = "Amazon Connect instance ID"
  value       = module.connect.instance_id
}

output "connect_phone_number" {
  description = "Claimed outbound phone number (E.164 format)"
  value       = module.connect.phone_number
}

output "connect_recording_bucket_name" {
  description = "S3 bucket storing call recordings"
  value       = module.connect.recording_bucket_name
}

output "outbound_call_api_endpoint" {
  description = "Endpoint to POST {\"phone_number\": \"+81...\"} to trigger an outbound test call"
  value       = module.connect_api.outbound_call_path
}
