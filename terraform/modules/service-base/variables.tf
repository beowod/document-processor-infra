variable "service_name" {
  type        = string
  description = "Name of the service"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "eks_cluster_arn" {
  type        = string
  description = "ARN of the EKS cluster"
}

variable "eks_oidc_issuer" {
  type        = string
  description = "OIDC issuer URL for the EKS cluster (without https:// prefix)"
}

variable "namespace" {
  type        = string
  default     = ""
  description = "Kubernetes namespace where the service runs. Defaults to service_name-environment."
}

variable "s3_versioning_enabled" {
  type        = bool
  default     = true
  description = "Enable S3 bucket versioning"
}

variable "sqs_visibility_timeout" {
  type        = number
  default     = 300
  description = "SQS message visibility timeout in seconds"
}

variable "sqs_message_retention" {
  type        = number
  default     = 604800
  description = "Message retention in seconds, default 7 days"
}

variable "sqs_max_receive_count" {
  type        = number
  default     = 3
  description = "Maximum number of receives before sending to DLQ"
}

variable "log_retention_days" {
  type        = number
  default     = 30
  description = "CloudWatch log group retention in days"
}

variable "enable_kms_encryption" {
  type        = bool
  default     = false
  description = "Enable KMS encryption for S3, SQS, and CloudWatch"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources"
}
