include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  parent_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  parent_inputs = local.parent_config.inputs
}

terraform {
  source = "./"
}

inputs = merge(
  local.parent_inputs,
  {
    csv_bucket_name = "${local.parent_inputs.project}-${local.parent_inputs.env}-${local.parent_inputs.account_id}-store-csv"
  }
)