resource "local_file" "frontend_config" {
  filename = "${path.module}/../frontend/config.js"

  content = <<-EOF
    window.MAILFLOW_API_URL = "${aws_apigatewayv2_api.mailflow.api_endpoint}";
  EOF

  file_permission = "0644"
}
