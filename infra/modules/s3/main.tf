resource "aws_s3_bucket" "mark_john_ignacio_html_resume" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.mark_john_ignacio_html_resume.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = var.cloudfront_oai_iam_arn
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.mark_john_ignacio_html_resume.arn}/*"
      },
      {
        Sid    = "AllowGitHubActionsUpload",
        Effect = "Allow",
        Principal = {
          AWS = var.github_actions_user_arn
        },
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.mark_john_ignacio_html_resume.arn,
          "${aws_s3_bucket.mark_john_ignacio_html_resume.arn}/*"
        ]
      }
    ]
  })
}

resource "null_resource" "upload_build_directory" {
  provisioner "local-exec" {
    command = "aws s3 sync ${var.build_directory_path} s3://${aws_s3_bucket.mark_john_ignacio_html_resume.bucket} --delete"
  }

  depends_on = [aws_s3_bucket.mark_john_ignacio_html_resume]
}

# resource "null_resource" "empty_s3_bucket" {
#   provisioner "local-exec" {
#     command = "aws s3 rm s3://${aws_s3_bucket.mark_john_ignacio_html_resume.bucket} --recursive"
#   }

#   depends_on = [aws_s3_bucket.mark_john_ignacio_html_resume]
# }

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.mark_john_ignacio_html_resume.bucket_regional_domain_name
}

output "bucket_name" {
  value = aws_s3_bucket.mark_john_ignacio_html_resume.bucket
}
