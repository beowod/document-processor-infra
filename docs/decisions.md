# Architecture Decision Records

## ADR-001: Helm over Kustomize

**Status**: Accepted

**Context**: The assignment allows either Helm or Kustomize for multi-environment Kubernetes configuration management.

**Decision**: Use Helm.

**Rationale**: Helm provides templating, packaging, versioning, and native ArgoCD integration. Values files cleanly separate environment-specific config without base/overlay complexity. Helm is the more common choice in production GitOps workflows.

---

## ADR-002: Terraform Module Structure

**Status**: Accepted

**Context**: Need to provision S3, SQS, IAM, and CloudWatch for the service.

**Decision**: Single reusable module at `terraform/modules/service-base/` with resource-per-file layout (`iam.tf`, `s3.tf`, `sqs.tf`, `cloudwatch.tf`).

**Rationale**: Clean separation of concerns. Module is reusable across services and environments. Variables and outputs provide a clear interface.

---

## ADR-003: IRSA for Pod Identity

**Status**: Accepted

**Context**: Pods need AWS API access for S3 and SQS.

**Decision**: Use IAM Roles for Service Accounts (IRSA) via OIDC federation.

**Rationale**: No static credentials, no instance profile sharing, least-privilege per-pod identity. Industry standard for EKS.

---

## ADR-004: SSE-S3 as Default Encryption

**Status**: Accepted

**Context**: S3 bucket needs encryption at rest.

**Decision**: Default to SSE-S3 (AES-256) with optional KMS via `enable_kms_encryption` variable.

**Rationale**: SSE-S3 is zero-cost, zero-management. KMS adds key rotation and audit trail but incurs per-request costs. Making it optional keeps the module flexible.

---

## ADR-005: ArgoCD Sync Strategy (Staging Auto / Production Manual)

**Status**: Accepted

**Context**: Need automated deployment with drift correction, but also a production safety gate.

**Decision**: Staging uses automated sync with prune and self-heal. Production requires manual sync approval.

**Rationale**: Staging benefits from fast feedback -- every merge to `master` deploys automatically. Production should not auto-deploy untested changes. An operator validates staging behavior, then explicitly triggers production sync via ArgoCD UI or CLI. This provides a lightweight promotion gate without requiring a separate branch or release orchestration system.

---

## ADR-006: Prometheus Operator CRDs for Monitoring

**Status**: Accepted

**Context**: Need metrics scraping and alerting.

**Decision**: Use ServiceMonitor and PrometheusRule CRDs.

**Rationale**: Standard approach with Prometheus Operator. Declarative, version-controlled monitoring config deployed alongside the application.

---

## ADR-007: Namespace-per-Environment Isolation

**Status**: Accepted (supersedes initial cluster-per-env assumption)

**Context**: Both staging and production ArgoCD Applications originally targeted the same namespace (`document-processor`) on the same cluster. This assumed separate clusters per environment, which prevents demonstrating both environments side by side and adds infrastructure cost.

**Decision**: Use namespace-per-environment on a single cluster: `document-processor-staging` and `document-processor-production`.

**Rationale**:
- **Demonstrability**: Both environments run simultaneously on one cluster, making it easy to compare configurations and validate differences.
- **Cost efficiency**: No need for multiple EKS clusters for non-production workloads.
- **Resource isolation**: Kubernetes namespaces provide resource quota, network policy, and RBAC boundaries between environments.
- **No name collisions**: ArgoCD uses the Application name as the Helm release name, so resource names are naturally prefixed (`document-processor-staging-*` vs `document-processor-production-*`).
- **`CreateNamespace=true`**: ArgoCD auto-creates the target namespace on first sync.

**Trade-off**: Namespace isolation is weaker than cluster isolation. For a production legal document processor, cluster-per-env would be the stronger choice. The namespace approach is appropriate for demonstration and cost-constrained environments.

---

## ADR-008: Terragrunt for DRY Multi-Environment Terraform

**Status**: Accepted

**Context**: The staging environment config (`main.tf`) duplicates backend configuration, provider setup, and variable declarations that would be identical across environments. Adding a production Terraform environment would require copying the entire file and changing a few values.

**Decision**: Add a Terragrunt layer alongside the existing standalone Terraform configuration.

**Rationale**:
- **DRY backend/provider**: The root `terragrunt.hcl` generates the S3 backend and AWS provider block automatically, keyed by the environment path. No duplication.
- **Environment variables in one place**: Each environment gets a single `env.hcl` file with region, EKS ARN, and OIDC issuer. Service-level `terragrunt.hcl` files read from it.
- **Multi-service scaling**: Adding another service to an environment requires only a new `terragrunt.hcl` in a subdirectory pointing to the appropriate module.
- **`run-all` support**: `terragrunt run-all apply` can deploy all services in an environment at once.
- **Non-breaking**: The standalone `main.tf` + `terraform.tfvars` path is preserved for users who don't have Terragrunt installed.
