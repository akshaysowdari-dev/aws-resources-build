include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.tfvars"))
  account_id  = get_aws_account_id()
}

terraform {
  source = "./"
}

inputs = {
  table_name = "csv-data-${get_env("TF_VAR_env", "dev")}"

  env        = local.common_vars.inputs.env
  region     = local.common_vars.inputs.region
  project    = local.common_vars.inputs.project
  account_id = local.account_id
}