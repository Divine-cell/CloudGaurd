terraform {
  backend "s3" {
    bucket = "backendstatefile123"
    key = "global/terraform/statefile"
    region = "us-east-1"
    encrypt = true
  }
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 6.0"
      } 
    }
}

provider "aws" {
  region = "us-east-1"
}

# #statefile bucket
resource "aws_s3_bucket" "backend_statefile" {
  bucket = "backendstatefile123"
  force_destroy = true

  tags = {
    Name = "Backend State file"
    Environment = "Dev"
  }
}

#statefile bucket versioning
resource "aws_s3_bucket_versioning" "statefile_versioning" {
  bucket = aws_s3_bucket.backend_statefile.id

  versioning_configuration {
    status = "Enabled"
  }
}
