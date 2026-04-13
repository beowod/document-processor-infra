output "iam_role_arn" {
  value       = aws_iam_role.service.arn
  description = "IAM role ARN for IRSA"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.this.id
  description = "S3 bucket name"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "S3 bucket ARN"
}

output "sqs_queue_url" {
  value       = aws_sqs_queue.main.url
  description = "Main SQS queue URL"
}

output "sqs_queue_arn" {
  value       = aws_sqs_queue.main.arn
  description = "Main SQS queue ARN"
}

output "sqs_dlq_url" {
  value       = aws_sqs_queue.dlq.url
  description = "Dead-letter queue URL"
}

output "sqs_dlq_arn" {
  value       = aws_sqs_queue.dlq.arn
  description = "Dead-letter queue ARN"
}

output "log_group_name" {
  value       = aws_cloudwatch_log_group.this.name
  description = "CloudWatch log group name"
}

output "log_group_arn" {
  value       = aws_cloudwatch_log_group.this.arn
  description = "CloudWatch log group ARN"
}

output "service_account_annotation" {
  value = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.service.arn
  }
  description = "Annotation map for Kubernetes service account"
}

output "k8s_namespace" {
  value       = local.k8s_namespace
  description = "Kubernetes namespace the IRSA trust policy is scoped to"
}
