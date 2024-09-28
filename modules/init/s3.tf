
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.organisation}-terraform-bucket-${var.stage}"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.stage
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    id     = "log"
    status = "Enabled"


    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "terraform_state" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]

  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}