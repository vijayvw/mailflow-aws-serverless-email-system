output "s3_bucket_name" {
  description = "S3 bucket used for CSV uploads"
  value       = aws_s3_bucket.email_uploads.bucket
}

output "lambda_function_name" {
  description = "Email processor Lambda function"
  value       = aws_lambda_function.email_processor.function_name
}

output "sns_topic_arn" {
  description = "SNS notification topic ARN"
  value       = aws_sns_topic.email_notifications.arn
}

output "ses_sender_email" {
  description = "SES sender email identity"
  value       = var.sender_email
}

output "aws_region" {
  description = "AWS deployment region"
  value       = var.aws_region
}
output "api_gateway_url" {
  description = "MailFlow API Gateway URL"
  value       = aws_apigatewayv2_api.mailflow.api_endpoint
}
output "frontend_url" {
  description = "MailFlow frontend S3 website URL"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}
