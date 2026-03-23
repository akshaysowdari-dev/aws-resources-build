include {
  path = find_in_parent_folders()
}

terraform {
  source = "./"
}

inputs = merge(
  local.include.inputs,  # Inherits: env, region, project, account_id from parent
  {
    bucket_name = "${local.include.inputs.project}-${local.include.inputs.env}-${local.include.inputs.account_id}-repo-adjusted"
  }
)