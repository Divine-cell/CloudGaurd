# Enable Security Hub
resource "aws_securityhub_account" "securityhub_config" {
  depends_on = [ aws_cloudtrail.cloudtrail, aws_guardduty_detector.guardduty_monitoring ]
}

# Subscibe to CIS aws foundations benachmark
# Tells security hhub to start evaluating resources against best practices 
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on = [aws_securityhub_account.securityhub_config ]
}