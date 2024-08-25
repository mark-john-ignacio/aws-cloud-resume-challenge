variable "bucket_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "cloudfront_oai_iam_arn" {
  type = string
}

variable "github_actions_user_arn" {
  type = string
}

variable "build_directory_path" {
  type        = string
  description = "Path to the build directory containing the website files"
}
