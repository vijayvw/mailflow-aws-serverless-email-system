locals {
  name_prefix = var.project_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
