resource "aws_cloudwatch_log_group" "this" {
  name              = "/eks/${var.environment}/${var.service_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_kms_encryption ? aws_kms_key.cloudwatch[0].arn : null
  tags              = local.common_tags
}

resource "aws_kms_key" "cloudwatch" {
  count               = var.enable_kms_encryption ? 1 : 0
  description         = "KMS key for ${var.service_name}-${var.environment} CloudWatch logs"
  enable_key_rotation = true
  tags                = local.common_tags
}

resource "aws_kms_key_policy" "cloudwatch" {
  count  = var.enable_kms_encryption ? 1 : 0
  key_id = aws_kms_key.cloudwatch[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAccountAccess"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogs"
        Effect    = "Allow"
        Principal = { Service = "logs.${data.aws_region.current.name}.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/eks/${var.environment}/${var.service_name}"
          }
        }
      },
    ]
  })
}

resource "aws_kms_alias" "cloudwatch" {
  count         = var.enable_kms_encryption ? 1 : 0
  name          = "alias/${var.service_name}-${var.environment}-cloudwatch"
  target_key_id = aws_kms_key.cloudwatch[0].key_id
}
