resource "aws_config_configuration_recorder" "recorder" {
  name     = "default"
  role_arn = aws_iam_role.aws_config_role.arn
  recording_group {
    all_supported = true
  }
}

resource "aws_config_configuration_recorder_status" "status" {
  name    = aws_config_configuration_recorder.recorder.name
  is_enabled = true
}

resource "aws_iam_role" "aws_config_role" {
  name = "aws_config_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
    bucket = aws_s3_bucket.config_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "AWSConfigAclCheck"
                Effect = "Allow"
                Principal = {
                    Service = "config.amazonaws.com"
                }
                Action = "s3:GetBucketAcl"
                Resource = "${aws_s3_bucket.config_bucket.arn}"

            },
            {
                Sid = "AWSConfigWrite"
                Effect = "Allow"
                Principal = {
                    Service = "config.amazonaws.com"
                }
                Action = "s3:PutObject"
                Resource = "${aws_s3_bucket.config_bucket.arn}/AWSConfig/logs/*"
                Condition = {
                    StringEquals = {
                        "s3:x-amz-acl" = "bucket-owner-full-control"
                    }
                }
            }
        ]
    
    })
}

resource "aws_iam_role_policy_attachment" "config_attach" {
  role       = aws_iam_role.aws_config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_delivery_channel" "delivery" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  s3_key_prefix   = "AWSConfig/logs"
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "cloudguard-config-bucket"
}

