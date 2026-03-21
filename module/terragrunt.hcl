remote_state {
  backend = "s3"
  config = {
    bucket         = "akshay-tf-state"
    key            = "terraform/${path_relative_to_include()}/tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
  }
}