resource "helm_release" "nginx-ingress-controller" {
  count = var.enable_nginx_ingress_controller == "true" ? 1 : 0

  namespace        = "nginx-ingress"
  create_namespace = true

  name       = "nginx-ingress-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.0"
  timeout    = 600

  set {
    name  = "rbac.create"
    value = "true"
  }

  depends_on = [
    module.alb_controller_irsa,
    helm_release.alb-ingress-controller
  ]
}
