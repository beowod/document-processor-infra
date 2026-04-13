# service-base Terraform Module

Reusable Terraform module that provisions a standard set of AWS resources for a Kubernetes-based microservice.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | ~> 5.0 |

## Usage

```hcl
module "document_processor" {
  source = "./modules/service-base"

  service_name    = "document-processor"
  environment     = "staging"
  eks_cluster_arn = "arn:aws:eks:us-east-1:123456789012:cluster/staging-cluster"
  eks_oidc_issuer = "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"

  s3_versioning_enabled  = true
  sqs_visibility_timeout = 300
  log_retention_days     = 30

  tags = {
    Team = "platform"
  }
}
```

## Resources Created

- **IAM Role** with OIDC trust policy for EKS IRSA
- **IAM Policy** with least-privilege S3, SQS, and CloudWatch Logs permissions
- **S3 Bucket** with versioning, encryption, lifecycle rules, and public access block
- **SQS Queue** with dead-letter queue, encryption, and configurable retention
- **CloudWatch Log Group** with configurable retention and optional KMS encryption

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| service_name | string | required | Name of the service |
| environment | string | required | Deployment environment |
| eks_cluster_arn | string | required | ARN of the EKS cluster |
| eks_oidc_issuer | string | required | OIDC issuer URL (without https://) |
| s3_versioning_enabled | bool | true | Enable S3 versioning |
| sqs_visibility_timeout | number | 300 | SQS visibility timeout in seconds |
| sqs_message_retention | number | 604800 | SQS message retention in seconds |
| sqs_max_receive_count | number | 3 | Max receives before DLQ |
| log_retention_days | number | 30 | CloudWatch log retention in days |
| enable_kms_encryption | bool | false | Use KMS instead of default encryption |
| tags | map(string) | {} | Additional resource tags |

## Outputs

| Name | Description |
|---|---|
| iam_role_arn | IAM role ARN for IRSA annotation |
| s3_bucket_name | S3 bucket name |
| s3_bucket_arn | S3 bucket ARN |
| sqs_queue_url | Main SQS queue URL |
| sqs_queue_arn | Main SQS queue ARN |
| sqs_dlq_url | Dead-letter queue URL |
| sqs_dlq_arn | Dead-letter queue ARN |
| log_group_name | CloudWatch log group name |
| log_group_arn | CloudWatch log group ARN |
| service_account_annotation | Map for Kubernetes SA IRSA annotation |
