inputs = {
  env        = "dev"
  region     = "ap-south-2"
  project    = "csvtodynamo"
  account_id = "371104900437"
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "akshay-dev-371104900437-tf-state-001"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "tf-lock-371104900437"
    encrypt        = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}