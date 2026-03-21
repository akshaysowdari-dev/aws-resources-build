include {
  path = find_in_parent_folders()
}

terraform {
  source = "./"
}

inputs = {
  table_name = "csv-data-${get_env("TF_VAR_env", "dev")}"
}