resource "aws_s3_object" "frontend_index" {
  bucket = aws_s3_bucket.frontend.id
  key    = "index.html"

  source = "${path.module}/../frontend/index.html"

  content_type = "text/html"

  etag = filemd5("${path.module}/../frontend/index.html")

  depends_on = [
    aws_s3_bucket.frontend
  ]
}

resource "aws_s3_object" "frontend_config" {
  bucket = aws_s3_bucket.frontend.id
  key    = "config.js"

  content = local_file.frontend_config.content

  content_type = "application/javascript"

  depends_on = [
    local_file.frontend_config
  ]
}
