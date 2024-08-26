bucket_name             = env("BUCKET_NAME")
acm_certificate_arn     = env("ACM_CERTIFICATE_ARN")
github_actions_user_arn = env("GITHUB_ACTIONS_USER_ARN")
aws_region              = env("AWS_REGION")
build_directory_path    = env("BUILD_DIRECTORY_PATH")

tags = {
  Name    = "mark_john_ignacio_html_resume"
  Project = "cloud-resume-project-with-terraform"
}
