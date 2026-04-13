terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "tramcase-terraform-state"
    key            = "staging/document-processor/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = "document-processor"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "eks_cluster_arn" {
  type        = string
  description = "ARN of the EKS cluster"
}

variable "eks_oidc_issuer" {
  type        = string
  description = "OIDC issuer URL (without https:// prefix)"
}

module "document_processor" {
  source = "../../../modules/service-base"

  service_name    = "document-processor"
  environment     = var.environment
  eks_cluster_arn = var.eks_cluster_arn
  eks_oidc_issuer = var.eks_oidc_issuer

  s3_versioning_enabled  = true
  sqs_visibility_timeout = 300
  log_retention_days     = 30

  tags = {
    Team = "platform"
  }
}

output "iam_role_arn" {
  value       = module.document_processor.iam_role_arn
  description = "IAM role ARN for IRSA annotation"
}

output "s3_bucket_name" {
  value       = module.document_processor.s3_bucket_name
  description = "S3 bucket name for document storage"
}

output "s3_bucket_arn" {
  value       = module.document_processor.s3_bucket_arn
  description = "S3 bucket ARN"
}

output "sqs_queue_url" {
  value       = module.document_processor.sqs_queue_url
  description = "SQS queue URL for job processing"
}

output "sqs_queue_arn" {
  value       = module.document_processor.sqs_queue_arn
  description = "SQS queue ARN"
}

output "sqs_dlq_url" {
  value       = module.document_processor.sqs_dlq_url
  description = "Dead-letter queue URL"
}

output "log_group_name" {
  value       = module.document_processor.log_group_name
  description = "CloudWatch log group name"
}
