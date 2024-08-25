

# Define the CloudFront distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.mark_john_ignacio_html_resume.bucket_regional_domain_name
    origin_id   = "S3-mark_john_ignacio_html_resume"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for mark_john_ignacio_html_resume"
  default_root_object = "index.html"

  aliases = ["portfolio.markjohnignacio.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-mark_john_ignacio_html_resume"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:010526260632:certificate/0e73b116-7f6b-4f4b-95d7-ee512bd84279"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }


  tags = {
    Name    = "mark_john_ignacio_html_resume-cdn"
    Project = "cloud-resume-project-with-terraform"
  }
}

resource "aws_dynamodb_table" "cloud_resume_terraform" {
  name           = "cloud-resume-terraform"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name    = "cloud-resume-terraform"
    Project = "cloud-resume-project-with-terraform"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name    = "iam_for_lambda"
    Project = "cloud-resume-project-with-terraform"
  }
}

resource "aws_iam_policy" "iam_policy_for_resume_project" {
  name        = "aws_iam_policy_for_terraform_resume_project_policy"
  path        = "/"
  description = "AWS IAM Policy for Terraform Resume Project"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "arn:aws:logs:*:*:*"
      },
      {
        Effect : "Allow",
        Action : [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        Resource : "${aws_dynamodb_table.cloud_resume_terraform.arn}"
      }
    ]
  })
  tags = {
    Name    = "iam_policy_for_resume_project"
    Project = "cloud-resume-project-with-terraform"
  }
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_resume_project.arn
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "myfunc" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  function_name    = "myfunc"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "func.lambda_handler"
  runtime          = "python3.8"
  tags = {
    Name    = "myfunc"
    Project = "cloud-resume-project-with-terraform"
  }
  depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

resource "aws_api_gateway_rest_api" "cloud_resume_api" {
  name        = "cloud-resume-api"
  description = "API for the Cloud Resume project"
}

resource "aws_api_gateway_resource" "views" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_api.id
  parent_id   = aws_api_gateway_rest_api.cloud_resume_api.root_resource_id
  path_part   = "views"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.cloud_resume_api.id
  resource_id   = aws_api_gateway_resource.views.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.cloud_resume_api.id
  resource_id             = aws_api_gateway_resource.views.id
  http_method             = aws_api_gateway_method.post_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.myfunc.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myfunc.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.cloud_resume_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_lambda_permission.apigw_lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.cloud_resume_api.id
  stage_name  = "prod"
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.cloud_resume_api.id
  resource_id   = aws_api_gateway_resource.views.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_api.id
  resource_id = aws_api_gateway_resource.views.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_api.id
  resource_id = aws_api_gateway_resource.views.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_api.id
  resource_id = aws_api_gateway_resource.views.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}

output "api_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/views"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.mark_john_ignacio_html_resume.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

resource "aws_dynamodb_table_item" "initial_item" {
  table_name = "cloud-resume-terraform"
  hash_key   = "id"

  item = <<ITEM
{
  "id": {"S": "1"},
  "views": {"N": "200"}
}
ITEM
}
