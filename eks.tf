locals {
  cluster_name    = (var.cluster_name != "" ? var.cluster_name : var.nuon_id)
  cluster_version = var.cluster_version

  instance_types = [var.default_instance_type]
  min_size       = var.min_size
  max_size       = var.max_size
  desired_size   = var.desired_size
}

provider "aws" {
  region = local.install_region
}

resource "aws_kms_key" "eks" {
  description = "Key for ${local.cluster_name} EKS cluster"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24.3"

  cluster_name                    = local.cluster_name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni = {
      most_recent = true
      preserve    = true
    }
  }

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = false

  access_entries = {
    "install:{{SessionName}}" = {
      principal_arn     = var.runner_install_role
      kubernetes_groups = [] # superceded by AmazonEKSClusterAdminPolicy
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
        eks_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    },
    # TODO(fd): we should have this passed in as an input in case this ever changes
    "odr-${local.cluster_name}" = {
      principal_arn     = module.odr_iam_role.iam_role_arn
      kubernetes_groups = [] # superceded by AmazonEKSClusterAdminPolicy
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
        eks_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

  }

  node_security_group_additional_rules = {}
  eks_managed_node_groups = {
    default = {
      instance_types = local.instance_types
      min_size       = local.min_size
      max_size       = local.max_size
      desired_size   = local.desired_size

      # NOTE(fd): automate the update of this on a regular interval
      launch_template = {
        name    = "default-2024112202580872790000001a"
        version = 2
      }

      iam_role_additional_policies = {
        additional = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  # HACK: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1986
  node_security_group_tags = {
    "kubernetes.io/cluster/${var.nuon_id}" = null
  }

  # this can't rely on default_tags.
  # full set of tags must be specified here :sob:
  tags = local.tags
}
