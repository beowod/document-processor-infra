include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/service-base"
}

inputs = {
  service_name    = "document-processor"
  environment     = local.env_vars.locals.environment
  eks_cluster_arn = local.env_vars.locals.eks_cluster_arn
  eks_oidc_issuer = local.env_vars.locals.eks_oidc_issuer

  s3_versioning_enabled  = true
  sqs_visibility_timeout = 300
  log_retention_days     = 30

  tags = {
    Team = "platform"
  }
}
