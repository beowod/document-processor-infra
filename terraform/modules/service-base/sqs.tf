resource "aws_sqs_queue" "dlq" {
  name                      = "${var.service_name}-${var.environment}-dlq"
  message_retention_seconds = var.sqs_message_retention
  sqs_managed_sse_enabled   = var.enable_kms_encryption ? false : true
  kms_master_key_id         = var.enable_kms_encryption ? aws_kms_key.sqs[0].arn : null
  tags                      = local.common_tags
}

resource "aws_sqs_queue" "main" {
  name                       = "${var.service_name}-${var.environment}"
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention
  sqs_managed_sse_enabled    = var.enable_kms_encryption ? false : true
  kms_master_key_id          = var.enable_kms_encryption ? aws_kms_key.sqs[0].arn : null

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })

  tags = local.common_tags
}

resource "aws_kms_key" "sqs" {
  count               = var.enable_kms_encryption ? 1 : 0
  description         = "KMS key for ${var.service_name}-${var.environment} SQS queues"
  enable_key_rotation = true
  tags                = local.common_tags
}

resource "aws_kms_alias" "sqs" {
  count         = var.enable_kms_encryption ? 1 : 0
  name          = "alias/${var.service_name}-${var.environment}-sqs"
  target_key_id = aws_kms_key.sqs[0].key_id
}
