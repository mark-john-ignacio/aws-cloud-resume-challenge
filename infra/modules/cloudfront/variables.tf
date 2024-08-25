variable "s3_bucket_domain_name" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}
