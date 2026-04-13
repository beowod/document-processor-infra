# Validation Commands

## Terraform Validation

### Module validation

```bash
cd terraform/modules/service-base
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

### Environment validation

```bash
cd terraform/environments/staging/document-processor
terraform init -backend=false
terraform validate
terraform plan  # requires AWS credentials
```

## Terragrunt Validation

```bash
# Validate staging
cd terraform/environments/staging/document-processor
terragrunt validate

# Validate production
cd terraform/environments/production/document-processor
terragrunt validate

# Plan all services in an environment
cd terraform/environments/staging
terragrunt run-all validate
```

## Helm Validation

### Lint charts

```bash
helm lint charts/document-processor
helm lint charts/document-processor -f charts/document-processor/values-staging.yaml
helm lint charts/document-processor -f charts/document-processor/values-production.yaml
```

### Render templates

```bash
# Render templates for staging
helm template document-processor charts/document-processor \
  -f charts/document-processor/values.yaml \
  -f charts/document-processor/values-staging.yaml \
  --namespace document-processor

# Render templates for production
helm template document-processor charts/document-processor \
  -f charts/document-processor/values.yaml \
  -f charts/document-processor/values-production.yaml \
  --namespace document-processor
```

## ArgoCD Manifest Validation

```bash
kubectl apply --dry-run=client -f argocd/document-processor.yaml
```

## Expected Outcomes

| Check | Expected Result |
|-------|-----------------|
| `terraform fmt` | No formatting changes needed |
| `terraform validate` | Success with 0 errors |
| `terragrunt validate` | Success for staging and production |
| `helm lint` | All charts pass linting |
| `helm template` | Generates valid YAML for Deployment, ServiceAccount, ConfigMap, HPA, PDB, ServiceMonitor, PrometheusRule, and Secret |
| ArgoCD dry-run | Valid Application manifests |
