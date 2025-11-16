variable "slack_webhook_url" {
  description = "The Slack webhook URL for sending notifications"
  type        = string
}

output "kms_key_alias" {
  description = "ID of the KMS key used for encrypting Lambda function data"
  value       = aws_kms_alias.threat_key_alias.name
}