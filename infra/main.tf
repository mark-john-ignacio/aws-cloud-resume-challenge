module "s3" {
  source                  = "./modules/s3"
  bucket_name             = var.bucket_name
  tags                    = var.tags
  cloudfront_oai_iam_arn  = module.cloudfront.oai_iam_arn
  github_actions_user_arn = var.github_actions_user_arn
  build_directory_path    = var.build_directory_path
}


module "cloudfront" {
  source                = "./modules/cloudfront"
  s3_bucket_domain_name = module.s3.bucket_regional_domain_name
  acm_certificate_arn   = var.acm_certificate_arn
  tags                  = var.tags
}

module "dynamodb" {
  source = "./modules/dynamodb"
  tags   = var.tags
}

module "lambda" {
  source             = "./modules/lambda"
  dynamodb_table_arn = module.dynamodb.dynamodb_table_arn
  tags               = var.tags
}

module "api_gateway" {
  source                     = "./modules/api_gateway"
  lambda_function_invoke_arn = module.lambda.lambda_function_arn
  lambda_function_name       = module.lambda.lambda_function_name
}
