# ----------------------------------------------------
# configure aws provider
# ----------------------------------------------------
provider "aws" {
  region = var.region
}

# ----------------------------------------------------
# create dynamo db for deployments locking 
# ----------------------------------------------------
resource "aws_dynamodb_table" "terraform_statelock" {
  name           = local.ddb_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# ----------------------------------------------------
# create S3 bucket that will be used for the backend
# ----------------------------------------------------
resource "aws_s3_bucket" "remote_state" {
  bucket = local.state_bucket_name

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Env = local.env
  }
}

# Every update to a file in the bucket creates a new version of that file
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Turn server-side encryption on by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.remote_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.remote_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}