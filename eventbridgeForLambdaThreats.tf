resource "aws_cloudwatch_event_rule" "lambda_threat_schedule" {
   name = "LambdaThreatTriggerRule"
   description = "Automatically trigger lambda to simulate threats every 5 miniutes"
   schedule_expression = ("rate(5 minutes)")
}

resource "aws_cloudwatch_event_target" "lambda_threat_trigger" {
  rule = aws_cloudwatch_event_rule.lambda_threat_schedule.name
  target_id = "LambdaThreatSimulationFunction"
  arn = aws_lambda_function.lambda_threat.arn
}