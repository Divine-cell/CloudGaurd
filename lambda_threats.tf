resource "aws_iam_role" "lambda_role_assumption" {
    name = "lambda_role_assumption"
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

resource "aws_iam_role_policy" "lambda_threat_simulation_policy" {
   name = "lambda_threat_simulation_policy"
   role = aws_iam_role.lambda_execution.id
   policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "s3:listBucket",
            "cloudtrail:updateTrail",
            "cloudtrail:stopLogging",
            "kms:DeleteKey",
            "kms:ScheduleKeyDeletion",
            "iam:CreateUser",
          ]
          Effect = "Allow"
          Resource = "arn:aws:logs:*:*:*"
        }
      ]
   })
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy_attachment" {
    role       = aws_iam_role.lambda_role_assumption.id
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource  "aws_lambda_function" "lambda_threat" {
    filename         = "lambda_threat.zip"
    function_name    = "LambdaThreatSimulationFunction"
    runtime          = "python3.12"
    handler          = "lambda_threat.lambda_handler"
    role             = aws_iam_role.lambda_role_assumption.arn
}

resource "aws_lambda_permission" "lambda_threat_eventbridge_permission" {
    statement_id  = "AllowExecutionFromEventBridge"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_threat.function_name
    principal     = "events.amazonaws.com"
    source_arn  = aws_cloudwatch_event_rule.lambda_threat_schedule.arn 
}

