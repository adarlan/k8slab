resource "helm_release" "ingress_nginx" {

  name = var.release_name

  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.7.1"

  namespace        = var.namespace
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {})]

  timeout = 600
}
