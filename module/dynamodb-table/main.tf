provider "aws" {
  region = var.region
}

resource "aws_dynamodb_table" "example" {
  name = ${var.table_name}

  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}