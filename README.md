# Document Processor Infrastructure

Infrastructure-as-Code for the **document-processor** microservice at TramCase. This repository contains a Terraform module for AWS resource provisioning, a Helm chart for Kubernetes deployment, and ArgoCD manifests for GitOps-based delivery.

## Overview

This project implements the complete infrastructure stack for a document processing service that:
- Processes legal documents uploaded by tenants
- Runs as an autoscaled Kubernetes deployment on EKS
- Uses S3 for document storage and SQS for job queuing
- Follows GitOps deployment patterns via ArgoCD
- Includes monitoring and alerting via Prometheus

The implementation covers three areas:
1. **Terraform Module** (Part 1) — Provisions IAM (IRSA), S3, SQS, and CloudWatch resources
2. **Helm Chart** (Part 2) — Packages Kubernetes manifests with multi-environment configuration
3. **ArgoCD Application** (Part 3) — Defines GitOps delivery with auto-sync, pruning, and self-healing

## Repository Structure

```
.
├── terraform/
│   ├── terragrunt.hcl              # Root Terragrunt config (remote state, provider)
│   ├── modules/
│   │   └── service-base/           # Reusable Terraform module
│   │       ├── main.tf             # Provider config, common tags
│   │       ├── variables.tf        # Module inputs
│   │       ├── outputs.tf          # Module outputs
│   │       ├── iam.tf              # IAM role (IRSA) + least-privilege policy
│   │       ├── s3.tf               # S3 bucket + versioning, encryption, lifecycle
│   │       ├── sqs.tf              # SQS queue + DLQ with redrive policy
│   │       ├── cloudwatch.tf       # CloudWatch log group + optional KMS
│   │       └── README.md           # Module documentation
│   └── environments/
│       ├── staging/
│       │   ├── env.hcl             # Staging environment variables
│       │   └── document-processor/
│       │       ├── terragrunt.hcl  # Terragrunt module invocation
│       │       ├── main.tf         # Standalone Terraform alternative
│       │       └── terraform.tfvars
│       └── production/
│           ├── env.hcl             # Production environment variables
│           └── document-processor/
│               └── terragrunt.hcl  # Terragrunt module invocation
├── charts/
│   └── document-processor/         # Helm chart
│       ├── Chart.yaml
│       ├── values.yaml             # Base/default values
│       ├── values-staging.yaml     # Staging overrides
│       ├── values-production.yaml  # Production overrides
│       └── templates/
│           ├── _helpers.tpl
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── serviceaccount.yaml
│           ├── configmap.yaml
│           ├── secret.yaml
│           ├── hpa.yaml
│           ├── pdb.yaml
│           ├── servicemonitor.yaml
│           └── prometheusrule.yaml
├── argocd/
│   └── document-processor.yaml     # ArgoCD Application manifests
├── docs/
│   ├── requirements-matrix.md      # Requirement traceability
│   ├── architecture.md             # Architecture overview
│   ├── decisions.md                # Architecture Decision Records
│   ├── validation.md               # Validation commands
│   ├── troubleshooting.md          # Common issues and fixes
│   └── cost-considerations.md      # Cost optimization notes
├── .github/
│   └── workflows/
│       └── validate.yml            # CI: terraform fmt/validate, helm lint/template
└── README.md
```

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | >= 1.5.0 | Infrastructure provisioning |
| Terragrunt | >= 0.50 | DRY Terraform wrapper (recommended) |
| AWS CLI | v2 | AWS authentication and management |
| Helm | >= 3.12 | Kubernetes package management |
| kubectl | >= 1.27 | Kubernetes cluster interaction |
| ArgoCD CLI | >= 2.8 (optional) | GitOps management |

**AWS Requirements:**
- AWS account with IAM permissions to create S3, SQS, IAM, CloudWatch resources
- EKS cluster with OIDC provider configured
- Prometheus Operator installed (for ServiceMonitor/PrometheusRule CRDs)

## Setup Instructions

### 1a. Terragrunt — Provision AWS Resources (Recommended)

Terragrunt wraps the Terraform module with DRY remote state and provider configuration. Environment-specific variables are defined in `env.hcl` files, eliminating duplication across environments.

```bash
cd terraform/environments/staging/document-processor

# Plan
terragrunt plan

# Apply
terragrunt apply

# View outputs
terragrunt output
```

To deploy all services in an environment at once:

```bash
cd terraform/environments/staging
terragrunt run-all apply
```

**How it works:**
- `terraform/terragrunt.hcl` — Root config that generates the S3 backend and AWS provider for every child module automatically
- `environments/<env>/env.hcl` — Per-environment variables (region, EKS ARN, OIDC issuer)
- `environments/<env>/document-processor/terragrunt.hcl` — Points to `modules/service-base` and passes inputs from `env.hcl`

### 1b. Terraform — Provision AWS Resources (Standalone Alternative)

If you prefer not to use Terragrunt, the standard Terraform path works independently:

```bash
cd terraform/environments/staging/document-processor

terraform init
terraform plan
terraform apply
terraform output
```

**Key outputs** to feed into Helm values:
- `iam_role_arn` → ServiceAccount IRSA annotation
- `s3_bucket_name` → ConfigMap S3_BUCKET_NAME
- `sqs_queue_url` → ConfigMap SQS_QUEUE_URL

### 2. Helm — Deploy to Kubernetes

```bash
# Lint the chart
helm lint charts/document-processor

# Deploy to staging
helm install document-processor-staging charts/document-processor \
  -f charts/document-processor/values.yaml \
  -f charts/document-processor/values-staging.yaml \
  -n document-processor-staging --create-namespace

# Deploy to production
helm install document-processor-production charts/document-processor \
  -f charts/document-processor/values.yaml \
  -f charts/document-processor/values-production.yaml \
  -n document-processor-production --create-namespace
```

### 3. ArgoCD — GitOps Deployment

```bash
# Apply the ArgoCD Application manifests
kubectl apply -f argocd/document-processor.yaml

# Monitor sync status
kubectl -n argocd get applications
```

## Validation Commands

```bash
# Terraform
terraform -chdir=terraform/modules/service-base fmt -check
terraform -chdir=terraform/modules/service-base init -backend=false && terraform -chdir=terraform/modules/service-base validate

# Helm
helm lint charts/document-processor
helm template doc-proc charts/document-processor \
  -f charts/document-processor/values-staging.yaml \
  --namespace document-processor

# ArgoCD
kubectl apply --dry-run=client -f argocd/document-processor.yaml
```

## Multi-Environment Configuration

| Parameter | Staging | Production |
|-----------|---------|------------|
| Replicas | 2 | 4 |
| CPU Request | 250m | 500m |
| Memory Request | 256Mi | 512Mi |
| CPU Limit | 500m | 1000m |
| Memory Limit | 512Mi | 1Gi |
| Log Level | debug | warn |
| Feature X | enabled | disabled |
| HPA Max | 5 | 10 |

## Environment Promotion Strategy

```
Feature Branch → PR → master → Staging (auto-sync) → Validate → Production (manual sync)
```

1. **Staging**: ArgoCD auto-syncs from `master` when changes merge. Immediate feedback via auto-sync + self-heal.
2. **Validation**: Monitor Prometheus alerts, check logs, verify functionality in staging.
3. **Production Promotion**: After staging validation, an operator triggers production sync manually via ArgoCD UI or `argocd app sync document-processor-production`. Production does **not** auto-deploy.
4. **Rollback**: ArgoCD UI → sync to previous revision, or `helm rollback`, or git revert + staging auto-sync. Production rollback is also manual.

**Safety controls**: PDB ensures 1+ pod during disruptions. HPA stabilization prevents thrashing. Readiness probes gate traffic to healthy pods. Production manual sync prevents untested changes from reaching production automatically.

## Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Multi-env config | Helm (not Kustomize) | Native templating, ArgoCD integration, cleaner value separation |
| Env isolation | Namespace-per-env | Both envs visible on one cluster, cost-efficient, demonstrable |
| Pod identity | IRSA via OIDC | No static creds, per-pod least-privilege, EKS standard |
| Encryption | SSE-S3 default, KMS optional | Zero cost by default, KMS opt-in for audit requirements |
| Monitoring | Prometheus Operator CRDs | Declarative, version-controlled, deployed with the app |
| GitOps | ArgoCD auto-sync (staging) / manual sync (production) | Staging: fast feedback; Production: explicit promotion gate |
| Terraform wrapper | Terragrunt | DRY backend/provider config, env vars in one place |

See [docs/decisions.md](docs/decisions.md) for detailed ADRs.

## Simplifications and Known Limitations

- **Placeholder image**: The Helm chart deploys `nginx-unprivileged` as a stand-in. The real document-processor image would serve `/healthz`, `/readyz`, and `/metrics` natively. Probe paths and extra volume mounts are overridden in per-environment values files to accommodate the placeholder; base values reflect the real application's expected behavior.
- **CloudWatch metrics exporter**: The `DocumentProcessorQueueDepthHigh` alert references an `aws_sqs_*` metric that requires a CloudWatch exporter (e.g., YACE) to be deployed alongside Prometheus. This is documented in the PrometheusRule template and is not deployed as part of this assignment.
- **Secrets management**: The Secret template demonstrates the pattern, but production secrets should be sourced from AWS Secrets Manager via External Secrets Operator or Sealed Secrets -- not committed to values files.

## What I'd Improve With More Time

1. **Network Policies** — Restrict pod-to-pod traffic with Kubernetes NetworkPolicy resources
2. **Terraform Testing** — Add `terratest` or `terraform test` for module validation
3. **Helm Schema Validation** — Add `values.schema.json` for input validation
4. **OIDC Provider Data Source** — Use `data "aws_eks_cluster"` to dynamically resolve OIDC issuer instead of hardcoding
5. **Pod Topology Spread** — Add `topologySpreadConstraints` for AZ-aware scheduling
6. **Canary Deployments** — Add ArgoCD Rollouts for progressive delivery
7. **Alertmanager Integration** — Configure notification routing for the PrometheusRule alerts
8. **CloudWatch Exporter** — Deploy YACE for SQS queue depth metrics in Prometheus
9. **Terraform State Locking** — Add DynamoDB table creation to a bootstrap module
10. **S3 Access Logging** — Enable server access logging for audit compliance

## Time Spent

| Section | Time |
|---------|------|
| Part 1: Terraform Module | ~1.5 hours |
| Part 2: Helm Chart + Templates | ~2 hours |
| Part 3: ArgoCD + GitOps | ~0.5 hours |
| Documentation + Audit | ~1.5 hours |
| **Total** | **~5.5 hours** |

## Additional Documentation

- [Architecture Overview](docs/architecture.md)
- [Architecture Decision Records](docs/decisions.md)
- [Requirements Traceability Matrix](docs/requirements-matrix.md)
- [Validation Guide](docs/validation.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Cost Considerations](docs/cost-considerations.md)
