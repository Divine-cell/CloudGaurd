# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWSLambdaBasicExecutionRole policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_execution.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function to notify Slack
resource "aws_lambda_function" "notify_slack" {
  filename = "lambda_function.zip"
  function_name = "NotifySlackFunction"
  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"
  role = aws_iam_role.lambda_execution.arn
  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

# lambda prmission to allow eventbridge to invoke lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
    statement_id  = "AllowExecutionFromEventBridge"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.notify_slack.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.securityhub_findings.arn
}