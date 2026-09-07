resource "aws_sns_topic" "email_notifications" {
  name = "${local.name_prefix}-notifications"

  tags = {
    Name    = "${local.name_prefix}-notifications"
    Project = var.project_name
  }
}

resource "aws_sns_topic_subscription" "email_notifications" {
  topic_arn = aws_sns_topic.email_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
