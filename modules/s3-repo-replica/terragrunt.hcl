include {
  path = find_in_parent_folders()
}

terraform {
  source = "./"
}

inputs = {
  env = get_env("TF_VAR_env", "dev")
}