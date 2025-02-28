locals {
  kyverno = {
    namespace  = "kyverno"
    value_file = "${path.module}/values/kyverno.yaml"
  }
}

// install kyverno
resource "helm_release" "kyverno" {
  namespace        = "kyverno"
  create_namespace = true

  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = "1.13.0" // TODO: make an input var?

  values = [
    file(local.kyverno.value_file),
  ]

  depends_on = [
    helm_release.metrics_server
  ]
}
