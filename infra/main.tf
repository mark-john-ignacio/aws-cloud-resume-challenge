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
    cloudfront_default_certificate = true
  }

  tags = {
    Name    = "mark-john-ignacio-html-resume-cdn"
    Project = "cloud-resume-project-with-terraform"
  }
}

# resource "aws_lambda_function" "myfunc" {
#     filename        = data.archive_file.zip.output_path
#     source_code_hash = data.archive_file.zip.output_base64sha256
#     function_name   = "myfunc"
#     role            = aws_iam_role.iam_for_lambda.arn
#     handler         = "func.lambda_handler"
#     runtime         = "python3.8"
#     tags = {
#         Name = "myfunc"
#         Project = "cloud-resume-project-with-terraform"
#     }
  
# }

# resource "aws_iam_role" "iam_for_lambda" {
#     name = "iam_for_lambda"
#     assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
#     tags = {
#         Name = "iam_for_lambda"
#         Project = "cloud-resume-project-with-terraform"
#     }
# }

# resource "aws_iam_policy" "iam_policy_for_resume_project" {
#     name       = "aws_iam_policy_for_terraform_resume_project_policy"
#     path      = "/"
#     description = "AWS IAM Policy for Terraform Resume Project"
#     policy    = jsonencode(
#         {
#             Version : "2012-10-17",
#             Statement : [
#                 {
#                     Effect : "Allow",
#                     Action : [
#                         "logs:CreateLogGroup",
#                         "logs:CreateLogStream",
#                         "logs:PutLogEvents"
#                     ],
#                     Resource : "arn:aws:logs:*:*:*"
#                 },
#                 {
#                     Effect : "Allow",
#                     Action : [
#                         "dynamodb:PutItem",
#                         "dynamodb:GetItem",
                        
#                         ],
#                     Resource : "arn:aws:dynamodb:*:*:table/cloudresume-test"
#                 }
#             ]   
#         })
#     tags = {
#         Name = "iam_policy_for_resume_project"
#         Project = "cloud-resume-project-with-terraform"
#     }  
# }

# resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
#     role = aws_iam_role.iam_for_lambda.name
#     policy_arn = aws_iam_policy.iam_policy_for_resume_project.arn
# }

# data "archive_file" "zip" {
#     type        = "zip"
#     source_dir  = "${path.module}/lambda"
#     output_path = "${path.module}/lambda.zip"
# }

# resource "aws_lambda_function_url" "url1" {
#     function_name = aws_lambda_function.myfunc.function_name
#     authorization_type = "NONE"

#     cors {
#         allow_credentials = true
#         allow_origins = ["http://www.09276477.xyz"]
#         allow_methods = ["*"]
#         allow_headers = ["date", "keep-alive"]
#         max_age = 3600
#     }
# }