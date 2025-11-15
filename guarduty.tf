# Enable GuardDuty with all available features
resource "aws_guardduty_detector" "guardduty_monitoring" {
  enable = true
}

resource "aws_guardduty_detector_feature" "all_features" {
    for_each = {
      "S3_DATA_EVENTS" = "ENABLED",
      "LAMBDA_NETWORK_LOGS" = "ENABLED",
      "EBS_MALWARE_PROTECTION" = "ENABLED",
      "RUNTIME_MONITORING" = "ENABLED"
    }
    detector_id = aws_guardduty_detector.guardduty_monitoring.id
    name = each.key 
    status = each.value
}