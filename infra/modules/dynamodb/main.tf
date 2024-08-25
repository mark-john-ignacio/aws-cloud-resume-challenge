resource "aws_dynamodb_table" "cloud_resume_terraform" {
  name           = "cloud-resume-terraform"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = var.tags
}

resource "aws_dynamodb_table_item" "initial_item" {
  table_name = aws_dynamodb_table.cloud_resume_terraform.name
  hash_key   = "id"

  item = jsonencode({
    "id"    = { S = "1" },
    "views" = { N = "200" }
  })

  lifecycle {
    ignore_changes = [item]
  }
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.cloud_resume_terraform.arn
}
