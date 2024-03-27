terraform {
  required_version = ">= 1.3.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
      # This is required in order for the calling TF project to pass in both the default and the no_tags aws providers.
      # Everything works fine in the calling project, but this causes `terraform validate` to fail when run against this module itself.
      # Apparently, this is a bug in Terraform: https://github.com/hashicorp/terraform/issues/28490
      configuration_aliases = [aws.no_tags]
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.1"
    }
  }
}
