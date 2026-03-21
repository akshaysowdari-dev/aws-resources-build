locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.tfvars"))
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
    bucket         = "${local.common_vars.project}-${local.common_vars.env}-${local.common_vars.account_id}-tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.common_vars.region
    dynamodb_table = "tf-lock-${local.common_vars.account_id}"
  }
}