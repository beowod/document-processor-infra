terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  common_tags = merge(var.tags, {
    Name        = var.service_name
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "terraform"
  })
}
