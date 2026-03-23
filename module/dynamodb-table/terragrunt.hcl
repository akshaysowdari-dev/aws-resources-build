include {
  path = find_in_parent_folders()
}

terraform {
  source = "./"
}

inputs = {
  table_name = "${project}-${env}-${account_id}-MCT-adjusted"
}