variable "slack_webhook_url" {
  description = "The Slack webhook URL for sending notifications"
  type        = string
}

variable "kms_key_id" {
  description = "ID of the KMS key used for encrypting Lambda function data"
  type        = string
}

variable "account_id" {
  description = "account id"
  type = number
}

variable "s3_bucket_id" {
  description = "id for s3 bucket"
  type = string
}

variable "region" {
  description = "AWS region"
  type = string
}


variable "public_key" {
  description = "public key for ec2 instance"
  type = string
}