# Enable Security Hub
resource "aws_securityhub_account" "securityhub_config" {}


# Tells security hub to start evaluating resources against best practices 
resource "aws_securityhub_standards_subscription" "foundational" {
   standards_arn = "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on = [aws_securityhub_account.securityhub_config ]
}

