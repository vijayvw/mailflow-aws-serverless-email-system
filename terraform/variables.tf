variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "mass-email-system"
}

variable "sender_email" {
  description = "Verified SES sender email address"
  type        = string
}
variable "notification_email" {
  description = "Email address that receives MailFlow campaign notifications"
  type        = string
}
