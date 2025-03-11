// install karpenter CRDS
// install karpenter
// create default ec2 nodeclass and default nodepool
locals {
  karpenter = {
    cluster_name    = local.cluster_name
    namespace       = "kube-system"
    version         = "1.2.2"
    discovery_key   = "karpenter.sh/discovery"
    discovery_value = local.cluster_name
  }
}


# NOTE: we use an instance_profile because the role changes between provisions
#       but the role is immutable on the ec2nodeclass
resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${local.karpenter.cluster_name}"
  role = module.eks.eks_managed_node_groups["karpenter"].iam_role_name
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.33.1"

  cluster_name        = local.karpenter.cluster_name
  namespace           = local.karpenter.namespace
  create_access_entry = false

  create_node_iam_role = false
  node_iam_role_arn    = module.eks.eks_managed_node_groups["karpenter"].iam_role_arn

  create_instance_profile = false

  enable_v1_permissions = true

  enable_irsa                     = true
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["kube-system:karpenter"]
  iam_role_tags = merge(local.tags, {
    karpenter = true
  })

  queue_name = ""

  depends_on = [
    module.eks
  ]
}

resource "helm_release" "karpenter_crd" {
  namespace        = local.karpenter.namespace
  create_namespace = false

  chart      = "karpenter-crd"
  name       = "karpenter-crd"
  repository = "oci://public.ecr.aws/karpenter"
  version    = local.karpenter.version

  wait = true

  values = [
    yamlencode({
      karpenter_namespace = local.karpenter.namespace
      webhook = {
        enabled     = true
        serviceName = "karpenter"
        port        = 8443
      }
    }),
  ]

  depends_on = [
    module.karpenter
  ]
}

resource "helm_release" "karpenter" {
  namespace        = local.karpenter.namespace
  create_namespace = false

  chart      = "karpenter"
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  version    = local.karpenter.version

  # https://github.com/aws/karpenter-provider-aws/blob/v1.2.2/charts/karpenter/values.yaml
  values = [
    yamlencode({
      replicas : 1
      logLevel : "debug"
      settings : {
        clusterEndpoint : module.eks.cluster_endpoint
        clusterName : local.karpenter.cluster_name
        interruptionQueue : module.karpenter.queue_name
        batchMaxDuration : "15s" # a little longer than the default
      }
      dnsPolicy : "ClusterFirst"
      controller : {
        resources : {
          requests : {
            cpu : 1
            memory : "1Gi"
          }
          limits : {
            cpu : 1
            memory : "1Gi"
          }
        }
      }
      serviceAccount : {
        annotations : {
          "eks.amazonaws.com/role-arn" : module.karpenter.iam_role_arn
        }
      }
      tolerations : [
        {
          key : "karpenter.sh/controller"
          value : "true"
          effect : "NoSchedule"
        },
        {
          key : "CriticalAddonsOnly"
          value : "true"
          effect : "NoSchedule"
        },
      ]
    }),
  ]

  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }

  depends_on = [
    helm_release.karpenter_crd
  ]
}

#
# EC2NodeClass: default
# https://karpenter.sh/v1.0/concepts/nodeclasses/
#
resource "kubectl_manifest" "karpenter_ec2nodeclass_default" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      instanceProfile = "KarpenterNodeInstanceProfile-${local.karpenter.cluster_name}"

      # https://karpenter.sh/v1.0/concepts/nodeclasses/#specamiselectorterms
      amiSelectorTerms = [
        {
          alias = "al2@latest"
        }
      ]
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = local.karpenter.discovery_value
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = local.karpenter.discovery_value
          }
        }
      ]
      tags = {
        "karpenter.sh/discovery" = local.karpenter.discovery_value
      }
    }
  })

  depends_on = [
    helm_release.karpenter
  ]
}

#
# nodepool: default
#
resource "kubectl_manifest" "karpenter_nodepool_default" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1" # we are on v1 now
    kind       = "NodePool"
    metadata = {
      name = "default"
    }
    spec = {
      limits = {
        cpu    = 1000
        memory = "1000Gi"
      }
      template = {
        spec = {
          expireAfter = "24h"
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }
          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values = [
                "spot",
                "on-demand",
              ]
            },
            {
              "key"      = "node.kubernetes.io/instance-type"
              "operator" = "In"
              "values"   = [var.default_instance_type]
            },
            {
              key      = "topology.kubernetes.io/zone"
              operator = "In"
              values = [ // this requires refinement
                "us-east-2a",
                "us-east-2b",
                "us-east-2c",
              ]
            },
          ]
        }
      }
      # https://karpenter.sh/v1.0/concepts/disruption/
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "5m"
        budgets = [
          // only allow one node to be disrupted at once
          {
            nodes = "1",
          },
        ]
      }
    }
  })

  depends_on = [
    kubectl_manifest.karpenter_ec2nodeclass_default,
    helm_release.karpenter,
  ]
}
