# Cloud Resume Challenge - Reusable Terraform Module
# This module creates a complete serverless resume website with visitor counter

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "cloud-resume"
}

variable "domain_name" {
  description = "Your custom domain name (optional)"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "build_directory_path" {
  description = "Path to your website build files"
  type        = string
  default     = "../build"
}

variable "github_actions_user_arn" {
  description = "ARN of GitHub Actions IAM user for CI/CD"
  type        = string
  default     = null
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for custom domain (optional)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

locals {
  # Generate unique bucket name
  bucket_name = "${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"
  
  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "cloud-resume-challenge"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Your existing modules with improved variables
module "s3" {
  source                  = "./modules/s3"
  bucket_name             = local.bucket_name
  tags                    = local.common_tags
  cloudfront_oai_iam_arn  = module.cloudfront.oai_iam_arn
  github_actions_user_arn = var.github_actions_user_arn
  build_directory_path    = var.build_directory_path
}

module "cloudfront" {
  source                = "./modules/cloudfront"
  s3_bucket_domain_name = module.s3.bucket_regional_domain_name
  acm_certificate_arn   = var.acm_certificate_arn
  tags                  = local.common_tags
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "${var.project_name}-${var.environment}-visitor-count"
  tags       = local.common_tags
}

module "lambda" {
  source             = "./modules/lambda"
  function_name      = "${var.project_name}-${var.environment}-visitor-counter"
  dynamodb_table_arn = module.dynamodb.dynamodb_table_arn
  tags               = local.common_tags
}

module "api_gateway" {
  source                     = "./modules/api_gateway"
  api_name                   = "${var.project_name}-${var.environment}-api"
  lambda_function_invoke_arn = module.lambda.lambda_function_arn
  lambda_function_arn        = module.lambda.lambda_function_arn
  lambda_function_name       = module.lambda.lambda_function_name
  aws_region                 = var.aws_region
}

# Outputs for reusability
output "website_url" {
  description = "CloudFront distribution URL"
  value       = module.cloudfront.domain_name
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_url
}

output "s3_bucket_name" {
  description = "S3 bucket name for website files"
  value       = module.s3.bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}
