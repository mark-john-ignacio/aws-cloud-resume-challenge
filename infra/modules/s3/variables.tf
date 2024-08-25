variable "build_directory" {
  description = "The directory of the build"
  type        = string
  default     = "../../../build"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "mark-john-ignacio-html-resume-abc123"
}

variable "tags" {
  description = "Tags for the S3 bucket"
  type        = map(string)
  default = {
    Name    = "mark_john_ignacio_html_resume"
    Project = "cloud-resume-project-with-terraform"
  }
}

variable "oai_comment" {
  description = "Comment for the CloudFront Origin Access Identity"
  type        = string
  default     = "OAI for S3 bucket"
}

variable "github_actions_iam_user_arn" {
  description = "IAM user ARN for GitHub Actions"
  type        = string
  default     = "arn:aws:iam::010526260632:user/github-actions-deploy-user"
}
