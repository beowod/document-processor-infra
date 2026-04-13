# Requirements Traceability Matrix

## SRE Platform Engineer — Take-Home Assignment

This matrix tracks every requirement from the assignment against its implementation status, evidence location, and validation method.

---

### Part 1 — Terraform Module (40%)

| ID | Requirement | Category | Priority | Status | Evidence | Validation Method |
|----|-------------|----------|----------|--------|----------|-------------------|
| TF-01 | Module at `terraform/modules/service-base/` | Terraform | Mandatory | Implemented | `terraform/modules/service-base/` | Directory exists with expected files |
| TF-02 | IAM Role with IRSA OIDC trust policy | Terraform | Mandatory | Implemented | `terraform/modules/service-base/iam.tf` | Inspect assume-role policy for OIDC provider |
| TF-03 | S3 read/write permissions scoped to bucket | Terraform | Mandatory | Implemented | `terraform/modules/service-base/iam.tf` | Verify IAM policy resource ARN matches bucket |
| TF-04 | SQS send/receive permissions | Terraform | Mandatory | Implemented | `terraform/modules/service-base/iam.tf` | Verify SQS actions and resource ARN |
| TF-05 | CloudWatch Logs permissions | Terraform | Mandatory | Implemented | `terraform/modules/service-base/iam.tf` | Verify logs:* actions in policy |
| TF-06 | S3 bucket with versioning | Terraform | Mandatory | Implemented | `terraform/modules/service-base/s3.tf` | Check `aws_s3_bucket_versioning` resource |
| TF-07 | S3 server-side encryption (SSE-S3/KMS) | Terraform | Mandatory | Implemented | `terraform/modules/service-base/s3.tf` | Check `aws_s3_bucket_server_side_encryption_configuration` |
| TF-08 | S3 lifecycle: IA after 90 days | Terraform | Mandatory | Implemented | `terraform/modules/service-base/s3.tf` | Check lifecycle rule transition days = 90 |
| TF-09 | S3 lifecycle: delete after 365 days | Terraform | Mandatory | Implemented | `terraform/modules/service-base/s3.tf` | Check lifecycle rule expiration days = 365 |
| TF-10 | S3 block public access | Terraform | Mandatory | Implemented | `terraform/modules/service-base/s3.tf` | Check `aws_s3_bucket_public_access_block` all = true |
| TF-11 | SQS queue with DLQ | Terraform | Mandatory | Implemented | `terraform/modules/service-base/sqs.tf` | Verify redrive_policy references DLQ ARN |
| TF-12 | SQS DLQ max receives = 3 | Terraform | Mandatory | Implemented | `terraform/modules/service-base/sqs.tf` | Check `maxReceiveCount` = 3 |
| TF-13 | SQS message retention 7 days | Terraform | Mandatory | Implemented | `terraform/modules/service-base/sqs.tf` | Check `message_retention_seconds` = 604800 |
| TF-14 | SQS visibility timeout 5 minutes | Terraform | Mandatory | Implemented | `terraform/modules/service-base/sqs.tf` | Check `visibility_timeout_seconds` = 300 |
| TF-15 | CloudWatch log group | Terraform | Mandatory | Implemented | `terraform/modules/service-base/cloudwatch.tf` | Verify `aws_cloudwatch_log_group` resource |
| TF-16 | Log retention 30 days | Terraform | Mandatory | Implemented | `terraform/modules/service-base/cloudwatch.tf` | Check `retention_in_days` = 30 |
| TF-17 | KMS encryption optional | Terraform | Mandatory | Implemented | `terraform/modules/service-base/cloudwatch.tf` | Check conditional `kms_key_id` |
| TF-18 | Required outputs (iam_role_arn, s3_bucket_name, s3_bucket_arn, sqs_queue_url, sqs_queue_arn, sqs_dlq_url, log_group_name) | Terraform | Mandatory | Implemented | `terraform/modules/service-base/outputs.tf` | Verify all 7 outputs present |
| TF-19 | Required variables (service_name, environment, eks_cluster_arn, eks_oidc_issuer, s3_versioning_enabled, sqs_visibility_timeout, log_retention_days, tags) | Terraform | Mandatory | Implemented | `terraform/modules/service-base/variables.tf` | Verify all 8 variables declared |
| TF-20 | Module README | Terraform | Mandatory | Implemented | `terraform/modules/service-base/README.md` | File exists with usage docs |
| TF-21 | Staging environment config | Terraform | Mandatory | Implemented | `terraform/environments/staging/document-processor/` | Directory contains main.tf + tfvars |
| TF-22 | Provider version pinned | Terraform | Mandatory | Implemented | `terraform/modules/service-base/main.tf` | Check `required_providers` version constraint |
| TF-23 | Terraform version constraint | Terraform | Mandatory | Fixed During Audit | `terraform/modules/service-base/main.tf` | Check `required_version` present |
| TF-24 | Consistent resource tagging | Terraform | Mandatory | Implemented | `terraform/modules/service-base/main.tf` | Verify `default_tags` in provider or locals |

### Part 2 — Kubernetes / Helm (40%)

| ID | Requirement | Category | Priority | Status | Evidence | Validation Method |
|----|-------------|----------|----------|--------|----------|-------------------|
| K8S-01 | Helm chart structure | Kubernetes | Mandatory | Implemented | `charts/document-processor/` | Chart.yaml + templates/ present |
| K8S-02 | Deployment with min 2 replicas | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/deployment.yaml` | Check `replicas` default ≥ 2 |
| K8S-03 | Resource requests and limits | Kubernetes | Mandatory | Implemented | `charts/document-processor/values.yaml` | Verify resources.requests and resources.limits |
| K8S-04 | Liveness and readiness probes | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/deployment.yaml` | Both probes defined in container spec |
| K8S-05 | Env from ConfigMap | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/deployment.yaml` | Check `envFrom` with `configMapRef` |
| K8S-06 | Env from Secrets | Kubernetes | Mandatory | Fixed During Audit | `charts/document-processor/templates/deployment.yaml` + `secret.yaml` | Check `envFrom` with `secretRef` and Secret template |
| K8S-07 | ServiceAccount with IRSA annotation | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/serviceaccount.yaml` | Verify `eks.amazonaws.com/role-arn` annotation |
| K8S-08 | Security context: non-root, read-only filesystem | Kubernetes | Mandatory | Fixed During Audit | `charts/document-processor/values.yaml` | Check `runAsNonRoot`, `readOnlyRootFilesystem` |
| K8S-09 | ConfigMap template | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/configmap.yaml` | Template file exists |
| K8S-10 | HPA with CPU 70%, min 2, max 10, 5m stabilization | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/hpa.yaml` | Verify all HPA parameters |
| K8S-11 | PDB with minAvailable 1 | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/pdb.yaml` | Check `minAvailable: 1` |
| K8S-12 | ServiceMonitor /metrics 30s | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/servicemonitor.yaml` | Path = /metrics, interval = 30s |
| K8S-13 | PrometheusRule — high error rate alert | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/prometheusrule.yaml` | Alert rule for error rate present |
| K8S-14 | PrometheusRule — queue depth alert | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/prometheusrule.yaml` | Alert rule for queue depth present |
| K8S-15 | PrometheusRule — pod restart alert | Kubernetes | Mandatory | Implemented | `charts/document-processor/templates/prometheusrule.yaml` | Alert rule for pod restarts present |
| K8S-16 | Staging replicas = 2 | Kubernetes | Mandatory | Implemented | `charts/document-processor/values-staging.yaml` | Check `replicaCount: 2` |
| K8S-17 | Production replicas = 4 | Kubernetes | Mandatory | Implemented | `charts/document-processor/values-production.yaml` | Check `replicaCount: 4` |
| K8S-18 | Different resource limits per env | Kubernetes | Mandatory | Implemented | `values-staging.yaml` + `values-production.yaml` | Compare resource blocks |
| K8S-19 | Different ConfigMap values per env | Kubernetes | Mandatory | Implemented | `values-staging.yaml` + `values-production.yaml` | Compare config sections |
| K8S-20 | Helm NOT Kustomize | Kubernetes | Mandatory | Implemented | `charts/document-processor/` | No kustomization.yaml present |

### Part 3 — ArgoCD (20%)

| ID | Requirement | Category | Priority | Status | Evidence | Validation Method |
|----|-------------|----------|----------|--------|----------|-------------------|
| ARGO-01 | ArgoCD Application manifest | ArgoCD | Mandatory | Implemented | `argocd/document-processor.yaml` | Valid ArgoCD Application YAML |
| ARGO-02 | Points to Helm chart | ArgoCD | Mandatory | Implemented | `argocd/document-processor.yaml` | `source.path` references chart directory |
| ARGO-03 | Automated sync with pruning | ArgoCD | Mandatory | Implemented | `argocd/document-processor.yaml` | `syncPolicy.automated.prune: true` |
| ARGO-04 | Self-heal enabled | ArgoCD | Mandatory | Implemented | `argocd/document-processor.yaml` | `syncPolicy.automated.selfHeal: true` |
| ARGO-05 | Promotion strategy documented | ArgoCD | Mandatory | Implemented | `README.md` | Promotion strategy section present |
| ARGO-06 | Rollback strategy documented | ArgoCD | Mandatory | Implemented | `README.md` | Rollback strategy section present |

### Documentation

| ID | Requirement | Category | Priority | Status | Evidence | Validation Method |
|----|-------------|----------|----------|--------|----------|-------------------|
| DOC-01 | README with overview | Documentation | Mandatory | Implemented | `README.md` | Overview section at top of file |
| DOC-02 | Prerequisites with versions | Documentation | Mandatory | Fixed During Audit | `README.md` | Prerequisites section with tool versions |
| DOC-03 | Setup instructions | Documentation | Mandatory | Implemented | `README.md` | Step-by-step setup section |
| DOC-04 | Architecture decisions | Documentation | Mandatory | Fixed During Audit | `docs/architecture.md` + `docs/decisions.md` | Docs exist with rationale |
| DOC-05 | What I'd improve | Documentation | Mandatory | Fixed During Audit | `README.md` | "What I'd Improve" section present |
| DOC-06 | Time spent | Documentation | Mandatory | Fixed During Audit | `README.md` | "Time Spent" section present |
| DOC-07 | Validation commands | Documentation | Mandatory | Fixed During Audit | `docs/validation.md` + `README.md` | Validation commands documented |

### Security

| ID | Requirement | Category | Priority | Status | Evidence | Validation Method |
|----|-------------|----------|----------|--------|----------|-------------------|
| SEC-01 | Least-privilege IAM | Security | Mandatory | Implemented | `terraform/modules/service-base/iam.tf` | Actions scoped to specific resources |
| SEC-02 | Encryption at rest | Security | Mandatory | Implemented | `s3.tf` + `sqs.tf` + `cloudwatch.tf` | SSE configured on all storage resources |
| SEC-03 | K8s security contexts | Security | Mandatory | Fixed During Audit | `values.yaml` | Non-root, read-only FS enforced |
| SEC-04 | No hardcoded secrets | Security | Mandatory | Implemented | All files | No plaintext credentials in repo |
| SEC-05 | S3 public access blocked | Security | Mandatory | Implemented | `terraform/modules/service-base/s3.tf` | All block_public_access flags = true |

### Bonus Items

| ID | Requirement | Category | Priority | Status | Evidence | Validation Method |
|----|-------------|----------|----------|--------|----------|-------------------|
| BONUS-01 | GitHub Actions CI workflow | Bonus | Bonus | Added During Audit | `.github/workflows/validate.yml` | Workflow file with validation steps |
| BONUS-02 | Cost optimization notes | Bonus | Bonus | Added During Audit | `docs/cost-considerations.md` | Document with cost analysis |
| BONUS-03 | Multi-environment examples | Bonus | Bonus | Implemented | `values-staging.yaml` + `values-production.yaml` | Separate values files per environment |
| BONUS-04 | Terragrunt configuration | Bonus | Bonus | Added During Audit | `terraform/terragrunt.hcl`, `environments/*/env.hcl`, `*/terragrunt.hcl` | DRY remote state and multi-env config |

---

## Coverage Summary

| Category | Implemented | Fixed During Audit | Total Mandatory | Coverage |
|----------|-------------|-------------------|-----------------|----------|
| Terraform (Part 1) | 22 | 1 | 24 | **24/24 (100%)** |
| Kubernetes / Helm (Part 2) | 18 | 2 | 20 | **20/20 (100%)** |
| ArgoCD (Part 3) | 6 | 0 | 6 | **6/6 (100%)** |
| Documentation | 2 | 5 | 7 | **7/7 (100%)** |
| Security | 4 | 1 | 5 | **5/5 (100%)** |
| **Totals** | **52** | **9** | **62** | **62/62 (100%)** |

**Bonus items included:** 3/3

> All 62 mandatory requirements are satisfied. 9 items were identified and remediated during the audit phase. 3 bonus items were added for extra credit.
