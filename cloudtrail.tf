# cloudtrail
resource "aws_cloudtrail" "cloudtrail" {
  name = "cloudtrail-1"
  depends_on = [ aws_s3_bucket.log_bucket ]
  s3_bucket_name = aws_s3_bucket.log_bucket.bucket
  include_global_service_events = false
  s3_key_prefix = "cloudtrail/logs"
}

# log bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket = "cloudtrail-log-bucket-12"
  force_destroy = true
  tags = {
    Name = "CloudTrail Log Bucket"
    Environment = "Dev"
  }
}

# log bucket policy to all0w cloudtrail access bucket
resource "aws_s3_bucket_policy" "log_bucket_policy" {
    bucket = aws_s3_bucket.log_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "AWSCloudTrailAclCheck"
                Effect = "Allow"
                Principal = {
                    Service = "cloudtrail.amazonaws.com"
                }
                Action = "s3:GetBucketAcl"
                Resource = "${aws_s3_bucket.log_bucket.arn}"

            },
            {
                Sid = "AWSCloudTrailWrite"
                Effect = "Allow"
                Principal = {
                    Service = "cloudtrail.amazonaws.com"
                }
                Action = "s3:PutObject"
                Resource = "${aws_s3_bucket.log_bucket.arn}/cloudtrail/logs/*"
                Condition = {
                    StringEquals = {
                        "s3:x-amz-acl" = "bucket-owner-full-control"
                    }
                }
            }
        ]
    
    })
}
