# Architecture Overview

The document-processor microservice runs on EKS with AWS-managed backing services. The infrastructure follows a GitOps model where:

- **AWS resources** (S3, SQS, IAM, CloudWatch) are provisioned via Terraform
- **Kubernetes workloads** are packaged as a Helm chart with environment-specific values
- **ArgoCD** manages deployment through git-driven reconciliation

## Infrastructure Components

| Component | Purpose | Key Configuration |
|-----------|---------|-------------------|
| **EKS Cluster** | Kubernetes control plane | Assumed pre-existing |
| **S3 Bucket** | Document storage | Versioning, SSE-S3 encryption, lifecycle (IA at 90d, expire at 365d), public access blocked |
| **SQS Queue** | Job processing | DLQ (3 max receives), 7-day retention, 5-min visibility timeout |
| **IAM Role (IRSA)** | Pod identity | OIDC federation, least-privilege for S3/SQS/CloudWatch |
| **CloudWatch Logs** | Centralized logging | 30-day retention |

## Deployment Flow

1. Engineer pushes code/config to GitHub
2. ArgoCD detects changes and compares desired vs live state
3. Helm chart is rendered with environment-specific values
4. Resources are synced to the cluster (auto-sync, prune, self-heal)

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  GitHub   │────▶│  ArgoCD  │────▶│   Helm   │────▶│   EKS    │
│  (Git)    │     │ (Detect) │     │ (Render) │     │  (Sync)  │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
```

## Observability Model

- **Prometheus ServiceMonitor** scrapes `/metrics` every 30 seconds
- **PrometheusRule** defines three alert conditions:
  - High error rate
  - Queue depth threshold exceeded
  - Excessive pod restarts
- **CloudWatch Logs** provides centralized log aggregation

## Security Model

| Layer | Mechanism |
|-------|-----------|
| **IRSA** | Pods authenticate to AWS via OIDC — no static credentials |
| **Least-privilege IAM** | Only required S3, SQS, and CloudWatch actions granted |
| **Pod security** | Non-root user (65534/nobody), read-only root filesystem, no privilege escalation |
| **Encryption at rest** | S3 (AES-256), SQS (SQS-managed SSE), optional KMS |
| **No hardcoded secrets** | Sensitive values injected via Kubernetes Secrets |

## Assumptions

- EKS cluster with OIDC provider is pre-existing
- Prometheus Operator is installed for ServiceMonitor/PrometheusRule CRDs
- ArgoCD is installed in the cluster
- ECR or other registry hosts the application container image
- Terraform state backend (S3 + DynamoDB) is pre-provisioned
