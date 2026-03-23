provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "repo" {
  bucket = var.bucket_name
}