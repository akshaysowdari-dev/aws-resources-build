locals {
  env        = get_env("TF_VAR_env", "dev")
  region     = "ap-south-2"
  project    = "csvtodynamo"

  account_id = get_env("AWS_ACCOUNT_ID", "")

  bucket_name = "akshay-${local.env}-${local.account_id}-tf-state-001"
  dynamodb_table = "tf-lock-${local.env}-${local.account_id}"
}

inputs = {
  env        = local.env
  region     = local.region
  project    = local.project
  account_id = local.account_id
}

remote_state {
  backend = "s3"

  config = {
    bucket         = local.bucket_name
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    dynamodb_table = local.dynamodb_table
    encrypt        = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}