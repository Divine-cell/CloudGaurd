# CloudWatch Event Rule to trigger Lambda on Security Hub findings
resource "aws_cloudwatch_event_rule" "securityhub_findings" {
   name = "SecurityHubFindingsRule"
   description = "Triggers lambda when security hub get an abnormal finding"
   event_pattern = jsonencode({
     "source": ["aws.securityhub"],
     "detail-type": [ "Security Hub Findings - high"]
   })
}

# CloudWatch Event Target to link the rule to the Lambda function
resource "aws_cloudwatch_event_target" "securityhub_lambda_target" {
  rule = aws_cloudwatch_event_rule.securityhub_findings.name
  target_id = "NotifySlackFunction"
  arn = aws_lambda_function.notify_slack.arn
}