provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "new_bucket" {
  bucket = "unique bucket name 2172919"
}

resource "aws_s3_bucket_public_access_block" "new_bucket_access" {
  bucket = aws_s3_bucket.new_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "new_bucket_ownership" {
  bucket = aws_s3_bucket.new_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}