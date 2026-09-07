resource "aws_s3_bucket" "email_uploads" {
  bucket = "${local.name_prefix}-uploads"

  tags = {
    Name        = "${local.name_prefix}-uploads"
    Project     = var.project_name
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "email_uploads" {
  bucket = aws_s3_bucket.email_uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "email_uploads" {
  bucket = aws_s3_bucket.email_uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "email_uploads" {
  bucket = aws_s3_bucket.email_uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "email_uploads" {
  bucket = aws_s3_bucket.email_uploads.id

  cors_rule {
    allowed_headers = ["*"]

    allowed_methods = [
      "PUT",
      "GET",
      "HEAD"
    ]

    allowed_origins = ["*"]

    expose_headers = [
      "ETag"
    ]

    max_age_seconds = 3000
  }
}
