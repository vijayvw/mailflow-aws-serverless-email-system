resource "aws_apigatewayv2_api" "mailflow" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]

    allow_methods = [
      "GET",
      "OPTIONS"
    ]

    allow_headers = [
      "Content-Type"
    ]
  }

  tags = {
    Name    = "${local.name_prefix}-api"
    Project = var.project_name
  }
}

resource "aws_apigatewayv2_integration" "upload_url" {
  api_id = aws_apigatewayv2_api.mailflow.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.upload_url.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "upload_url" {
  api_id = aws_apigatewayv2_api.mailflow.id

  route_key = "GET /upload-url"
  target    = "integrations/${aws_apigatewayv2_integration.upload_url.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.mailflow.id

  name        = "$default"
  auto_deploy = true

  tags = {
    Name    = "${local.name_prefix}-api-stage"
    Project = var.project_name
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id = "AllowAPIGatewayInvoke"
  action       = "lambda:InvokeFunction"

  function_name = aws_lambda_function.upload_url.function_name

  principal  = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.mailflow.execution_arn}/*/*"
}
