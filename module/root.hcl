locals {
  common_vars = read_terragrunt_config("common.tfvars")
  account_id  = get_aws_account_id()
}

inputs = {
  env        = local.common_vars.inputs.env
  region     = local.common_vars.inputs.region
  project    = local.common_vars.inputs.project
  account_id = local.account_id
}
  
remote_state {
  backend = "s3"

  config = {
    bucket         = "akshay-${local.common_vars.inputs.env}-${local.account_id}-tf-state-001"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.common_vars.inputs.region
    dynamodb_table = "tf-lock-${local.account_id}"
    encrypt        = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}