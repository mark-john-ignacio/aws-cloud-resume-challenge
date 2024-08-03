resource "aws_s3_bucket" "mark-john-ignacio-html-resume" {
    bucket = "mark-john-ignacio-html-resume"
    tags = {
        Name = "mark-john-ignacio-html-resume"
        Project = "cloud-resume-project-with-terraform"
    }
}

resource "null_resource" "upload_build_directory" {
    provisioner "local-exec" {
        command = "aws s3 sync ../build s3://${aws_s3_bucket.mark-john-ignacio-html-resume.bucket} --delete"
    }

    depends_on = [aws_s3_bucket.mark-john-ignacio-html-resume]
}

# Needed for destroying the bucket
# resource "null_resource" "empty_s3_bucket" {
#     provisioner "local-exec" {
#         command = "aws s3 rm s3://${aws_s3_bucket.mark-john-ignacio-html-resume.bucket} --recursive"
#     }

#     depends_on = [aws_s3_bucket.mark-john-ignacio-html-resume]
# }

# Define the origin access identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for S3 bucket"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.mark-john-ignacio-html-resume.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path}"
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.mark_john_ignacio_html_resume.arn}/*"
      },
      {
        Sid = "AllowGitHubActionsUpload",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::010526260632:user/github-actions-deploy-user"
        },
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.mark_john_ignacio_html_resume.arn}",
          "${aws_s3_bucket.mark_john_ignacio_html_resume.arn}/*"
        ]
      }
    ]
  })
}

# Define the CloudFront distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.mark_john_ignacio_html_resume.bucket_regional_domain_name
    origin_id   = "S3-mark-john-ignacio-html-resume"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for mark-john-ignacio-html-resume"
  default_root_object = "index.html"
  
  aliases = ["resume.09276477.xyz"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-mark-john-ignacio-html-resume"

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
  
  retain_on_delete = true

  tags = {
    Name    = "mark-john-ignacio-html-resume-cdn"
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

  attribute {
    name = "views"
    type = "N"
  }

  tags = {
    Name    = "cloud-resume-terraform"
    Project = "cloud-resume-project-with-terraform"
  }
}

resource "aws_appautoscaling_target" "dynamodb_read_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/cloud-resume-terraform"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_read_policy" {
  name               = "DynamoDBReadCapacityUtilization"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "dynamodb_write_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/cloud-resume-terraform"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_lambda_function" "myfunc" {
    filename        = data.archive_file.zip.output_path
    source_code_hash = data.archive_file.zip.output_base64sha256
    function_name   = "myfunc"
    role            = aws_iam_role.iam_for_lambda.arn
    handler         = "func.lambda_handler"
    runtime         = "python3.8"
    tags = {
        Name = "myfunc"
        Project = "cloud-resume-project-with-terraform"
    }
  
}

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
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
        Name = "iam_for_lambda"
        Project = "cloud-resume-project-with-terraform"
    }
}

resource "aws_iam_policy" "iam_policy_for_resume_project" {
    name       = "aws_iam_policy_for_terraform_resume_project_policy"
    path      = "/"
    description = "AWS IAM Policy for Terraform Resume Project"
    policy    = jsonencode(
        {
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
                        
                        ],
                    Resource : "${aws_dynamodb_table.cloud_resume_terraform.arn}"
                }
            ]   
        })
    tags = {
        Name = "iam_policy_for_resume_project"
        Project = "cloud-resume-project-with-terraform"
    }  
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
    role = aws_iam_role.iam_for_lambda.name
    policy_arn = aws_iam_policy.iam_policy_for_resume_project.arn
}

data "archive_file" "zip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda"
    output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function_url" "url1" {
    function_name = aws_lambda_function.myfunc.function_name
    authorization_type = "NONE"

    cors {
        allow_credentials = true
        allow_origins = ["http://resume.09276477.xyz"]
        allow_methods = ["*"]
        allow_headers = ["date", "keep-alive"]
        max_age = 3600
    }
}