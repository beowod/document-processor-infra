# Troubleshooting Guide

## Common Issues

### Terraform init fails with backend error

**Symptom**: `Error configuring S3 Backend`

**Cause**: S3 state bucket or DynamoDB table doesn't exist.

**Fix**: Create the backend resources first, or use `backend "local" {}` for testing.

---

### Pods stuck in ImagePullBackOff

**Symptom**: Pods show `ErrImagePull` or `ImagePullBackOff`.

**Cause**: Container image doesn't exist in the specified registry.

**Fix**: Build and push the application image to the configured ECR repository.

---

### ArgoCD sync fails with CRD not found

**Symptom**: `The Kubernetes API could not find monitoring.coreos.com/ServiceMonitor`

**Cause**: Prometheus Operator CRDs not installed on the cluster.

**Fix**: Install Prometheus Operator or apply CRDs manually:

```bash
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
```

---

### ArgoCD sync fails with namespace not found

**Symptom**: `namespaces "document-processor" not found`

**Cause**: CreateNamespace sync option not working with ServerSideApply.

**Fix**: Remove `ServerSideApply=true` from syncOptions, or create the namespace manually:

```bash
kubectl create namespace document-processor
```

---

### HPA shows unknown CPU metrics

**Symptom**: `cpu: <unknown>/70%`

**Cause**: metrics-server not installed or pods not generating CPU metrics yet.

**Fix**: Install metrics-server, then wait for metrics collection (typically 60–90 seconds):

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

### IRSA not working (pods can't access AWS)

**Symptom**: AWS SDK errors like `NoCredentialProviders`.

**Cause**: ServiceAccount annotation missing or OIDC provider not configured.

**Fix**:

1. Verify ServiceAccount has the correct annotation:
   ```bash
   kubectl get sa document-processor -n document-processor -o yaml | grep eks.amazonaws.com/role-arn
   ```

2. Verify EKS OIDC provider is registered in IAM:
   ```bash
   aws iam list-open-id-connect-providers
   ```
