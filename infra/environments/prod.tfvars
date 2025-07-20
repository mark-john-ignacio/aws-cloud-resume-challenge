# Production Environment Configuration
project_name     = "john-doe-resume"
environment      = "prod"
aws_region       = "us-east-1"
build_directory_path = "../build"

# Custom domain for production
domain_name = "johndoe.com"
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-prod-cert"

# GitHub Actions for CI/CD
github_actions_user_arn = "arn:aws:iam::123456789012:user/github-actions-prod"
