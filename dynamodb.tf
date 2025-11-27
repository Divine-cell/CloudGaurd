# To store finding id to avoid finding duplication
resource "aws_dynamodb_table" "finding_id_table" {
   name = "security_findings_table"
   billing_mode = "PAY_PER_REQUEST"
   hash_key = "FindingID"

   attribute {
     name = "FindingID"
     type = "S"
   }

   ttl {
     attribute_name = "ttl"
     enabled = true
   }

   tags = {
     Name = "finding_id_table"
     Environment = "Dev"
   }
}
