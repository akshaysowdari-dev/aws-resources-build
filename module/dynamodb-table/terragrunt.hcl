include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "./"
}

inputs = merge(
  local.include.inputs,  # Inherits: env, region, project, account_id from parent
  {
    table_name = "${local.include.inputs.project}-${local.include.inputs.env}-${local.include.inputs.account_id}-MCT-adjusted"
  }
)