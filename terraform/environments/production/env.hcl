locals {
  environment     = "production"
  aws_region      = "us-east-1"
  eks_cluster_arn = "arn:aws:eks:us-east-1:123456789012:cluster/production-cluster"
  eks_oidc_issuer = "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
}
