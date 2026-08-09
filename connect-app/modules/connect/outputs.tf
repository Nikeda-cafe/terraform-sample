output "instance_id" {
  description = "Amazon Connect instance ID"
  value       = aws_connect_instance.this.id
}

output "instance_arn" {
  description = "Amazon Connect instance ARN"
  value       = aws_connect_instance.this.arn
}

output "phone_number" {
  description = "Claimed outbound phone number (E.164 format)"
  value       = aws_connect_phone_number.outbound.phone_number
}

output "phone_number_arn" {
  description = "ARN of the claimed phone number"
  value       = aws_connect_phone_number.outbound.arn
}

output "contact_flow_id" {
  description = "Contact flow ID used for outbound test calls"
  value       = aws_connect_contact_flow.outbound_test.contact_flow_id
}

output "queue_id" {
  description = "Default queue ID used for outbound calls"
  value       = data.aws_connect_queue.default.queue_id
}

output "recording_bucket_name" {
  description = "S3 bucket name storing call recordings"
  value       = aws_s3_bucket.call_recordings.bucket
}
