include {
  path = find_in_parent_folders()
}

terraform {
  source = "./"
}

inputs = {
  bucket_name = "${var.project}-${var.env}-${var.account_id}-repo-adjusted"
}