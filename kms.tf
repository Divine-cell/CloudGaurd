resource "aws_kms_key" "threats_simulation_key" {
    description             = "KMS key for encrypting Lambda function data"
    deletion_window_in_days = 7
    
    tags = {
        Name        = "LambdaThreatSimulationKey"
        Environment = "Dev"
    }
}

resource "aws_kms_alias" "threat_key_alias" {
  name = "alias/lambda_threats_simulation_key"
  target_key_id = aws_kms_key.threats_simulation_key.id
}