resource "aws_lambda_function" "myfunc" {
    filename        = data.archive_file.zip.output_path
    source_code_hash = data.archive_file.zip.output_base64sha256
    function_name   = "myfunc"
    role            = aws_iam_role.iam_for_lambda.arn
    handler         = "func.lambda_handler"
    runtime         = "python3.8"
  
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
                    Resource : "arn:aws:dynamodb:*:*:table/cloudresume-test"
                }
            ]   
        })
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
        allow_origins = ["http://www.09276477.xyz"]
        allow_methods = ["*"]
        allow_headers = ["date", "keep-alive"]
        max_age = 3600
    }
}