terraform {
  required_version = ">= 1.3.7"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
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