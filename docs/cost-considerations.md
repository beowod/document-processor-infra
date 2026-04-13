# Cost Considerations

## Storage Costs

- **S3 Lifecycle Policy**: Objects transition to Infrequent Access after 90 days (40–50% cost reduction per GB). Expired after 365 days to prevent unbounded storage growth.
- **S3 Versioning**: Enabled for data protection. Consider lifecycle rules for non-current version expiration to control versioning costs.

## Compute Costs

- **HPA**: Autoscaling from 2 to 10 replicas based on CPU prevents over-provisioning. Scale-down stabilization (5 minutes) avoids thrashing.
- **Resource Requests vs Limits**: Requests set lower than limits allows bin-packing. Staging uses smaller resources (100m/64Mi) than production (500m/512Mi).

## Messaging Costs

- **SQS**: Standard queue pricing is per-request. DLQ with max 3 receives prevents infinite retry loops that would increase costs.
- **Visibility Timeout**: 5-minute timeout reduces duplicate processing and wasted compute.

## Logging Costs

- **CloudWatch Log Retention**: 30-day retention balances debugging needs against storage costs. Consider 7 days for development environments.
- **KMS Encryption**: Optional and disabled by default. Enables audit trail but adds ~$1/month per key plus per-API-call costs.

## Encryption Costs

| Method | Cost | Notes |
|--------|------|-------|
| **SSE-S3 (AES-256)** | Free | Default, zero additional cost |
| **KMS** | ~$0.03 per 10,000 requests | Optional upgrade; provides key rotation audit trail |
| **SQS SSE (SQS-managed)** | Free | No additional cost |
| **SQS SSE (KMS-based)** | ~$0.03 per 10,000 requests | Same KMS pricing as above |

## Recommendations

1. **Use Spot Instances** for staging node groups (60–90% savings)
2. **Consider S3 Intelligent-Tiering** for unpredictable access patterns
3. **Set non-current version expiration** on S3 to 30 days
4. **Use reserved capacity** for production EKS nodes if usage is predictable
