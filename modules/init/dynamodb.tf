resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.organisation}-terraform-lock-table-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = var.stage
  }
}
