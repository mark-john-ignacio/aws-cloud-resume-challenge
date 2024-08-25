module "s3" {
  source = "../modules/s3"
  # Pass necessary variables
}

module "cloudfront" {
  source = "../modules/cloudfront"
  # Pass necessary variables
}

module "lambda" {
  source = "../modules/lambda"
  # Pass necessary variables
}

module "dynamodb" {
  source = "../modules/dynamodb"
  # Pass necessary variables
}

module "api_gateway" {
  source = "../modules/api_gateway"
  # Pass necessary variables
}
