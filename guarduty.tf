# Enable GuardDuty with all available features
resource "aws_guardduty_detector" "guardduty_monitoring" {
  enable = true

  finding_publishing_frequency = "ONE_HOUR"

  
}

resource "aws_guardduty_detector_feature" "all_features" {
    for_each = {
      "S3_DATA_EVENTS" = "ENABLED",
      "LAMBDA_NETWORK_LOGS" = "ENABLED",
      "EBS_MALWARE_PROTECTION" = "ENABLED",
      "RUNTIME_MONITORING" = "ENABLED",
      "EKS_RUNTIME_MONITORING" = "ENABLED",
      "RDS_LOGIN_EVENTS" = "ENABLED",
      "EKS_AUDIT_LOGS" = "ENABLED",

    }
    detector_id = aws_guardduty_detector.guardduty_monitoring.id
    name = each.key 
    status = each.value
}