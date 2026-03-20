resource "aws_s3_bucket" "repo_bucket" {
  bucket = "repo-replica-${var.env}"
}