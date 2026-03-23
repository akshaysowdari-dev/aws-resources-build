locals {
  account_id = get_aws_account_id()
}

inputs = {
  env        = "dev"
  region     = "ap-south-2"
  project    = "csvtodynamo"
  account_id = local.account_id
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "akshay-dev-${local.account_id}-tf-state-001"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "tf-lock-${local.account_id}"
    encrypt        = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}