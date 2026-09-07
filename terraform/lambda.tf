data "archive_file" "email_processor" {
  type = "zip"

  source {
    content  = file("${path.module}/../lambda/email_processor.py")
    filename = "email_processor.py"
  }

  source {
    content  = file("${path.module}/../lambda/email_template.html")
    filename = "email_template.html"
  }

  output_path = "${path.module}/email_processor.zip"
}


resource "aws_lambda_function" "email_processor" {
  function_name = "${local.name_prefix}-processor"

  role = aws_iam_role.lambda_execution.arn

  runtime = "python3.12"
  handler = "email_processor.lambda_handler"

  filename         = data.archive_file.email_processor.output_path
  source_code_hash = data.archive_file.email_processor.output_base64sha256

  timeout     = 60
  memory_size = 256

  environment {
    variables = {
      SENDER_EMAIL  = var.sender_email
      SNS_TOPIC_ARN = aws_sns_topic.email_notifications.arn
    }
  }

  tags = {
    Name    = "${local.name_prefix}-processor"
    Project = var.project_name
  }
}


# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id = "AllowS3Invoke"
  action       = "lambda:InvokeFunction"

  function_name = aws_lambda_function.email_processor.function_name

  principal = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.email_uploads.arn
}


# Trigger Lambda when a CSV is uploaded to S3
resource "aws_s3_bucket_notification" "email_upload_notification" {
  bucket = aws_s3_bucket.email_uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.email_processor.arn

    events = [
      "s3:ObjectCreated:*"
    ]

    filter_suffix = ".csv"
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}


data "archive_file" "upload_url" {
  type        = "zip"
  source_file = "${path.module}/../lambda/upload_url.py"
  output_path = "${path.module}/upload_url.zip"
}


resource "aws_lambda_function" "upload_url" {
  function_name = "${local.name_prefix}-upload-url"

  role = aws_iam_role.lambda_execution.arn

  runtime = "python3.12"
  handler = "upload_url.lambda_handler"

  filename         = data.archive_file.upload_url.output_path
  source_code_hash = data.archive_file.upload_url.output_base64sha256

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.email_uploads.bucket
    }
  }

  tags = {
    Name    = "${local.name_prefix}-upload-url"
    Project = var.project_name
  }
}
