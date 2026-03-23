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

inputs = local.parent_inputs