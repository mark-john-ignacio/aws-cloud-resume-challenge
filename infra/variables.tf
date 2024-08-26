# variable "aws_access_key" {
#   description = "AWS access key"
#   type        = string
# }

# variable "aws_secret_key" {
#   description = "AWS secret key"
#   type        = string
# }

variable "bucket_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "acm_certificate_arn" {
  type = string
}

variable "github_actions_user_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "build_directory_path" {
  type        = string
  description = "Path to the build directory containing the website files"
}
