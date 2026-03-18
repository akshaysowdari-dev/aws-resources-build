terraform {
  source = "../modules/dynamodb"

  extra_arguments "var_files" {
    commands = ["apply", "plan", "destroy", "output"]

    required_var_files = [
      "${get_terragrunt_dir()}/${get_env("ENV", "dev")}.tfvars"
    ]
  }
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state-bucket"
    key            = "${get_env("ENV", "dev")}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}