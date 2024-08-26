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

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.cloud_resume_terraform.arn
}

output "dynamodb_table_name_for_lock" {
  value = aws_dynamodb_table.terraform_lock.name
}
