resource "aws_s3_bucket" "this" {
  bucket = "${var.service_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.s3_versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms_encryption ? "aws:kms" : "AES256"
      kms_master_key_id = var.enable_kms_encryption ? aws_kms_key.s3[0].arn : null
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "lifecycle"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "s3" {
  count               = var.enable_kms_encryption ? 1 : 0
  description         = "KMS key for ${var.service_name}-${var.environment} S3 bucket"
  enable_key_rotation = true
  tags                = local.common_tags
}

resource "aws_kms_alias" "s3" {
  count         = var.enable_kms_encryption ? 1 : 0
  name          = "alias/${var.service_name}-${var.environment}-s3"
  target_key_id = aws_kms_key.s3[0].key_id
}
