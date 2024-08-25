output "lambda_function_arn" {
  value = aws_lambda_function.myfunc.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.myfunc.function_name
}
