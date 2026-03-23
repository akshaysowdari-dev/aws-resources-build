provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "repo" {
  bucket = var.bucket_name1

  versioning {
    enabled = true
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}

resource "aws_s3_bucket" "csv_store" {
  bucket = var.bucket_name2

  versioning {
    enabled = true
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}