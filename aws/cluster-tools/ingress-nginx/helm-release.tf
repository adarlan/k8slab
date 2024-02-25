resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.1"

  namespace        = "ingress-nginx"
  create_namespace = true

  values = [file("${path.module}/values.yaml")]
}
