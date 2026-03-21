terraform {
  backend "s3" {}
}

resource "aws_s3_bucket" "repo" {
  bucket = "${var.project}-${var.env}-${var.account_id}-repo"
}