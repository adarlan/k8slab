resource "helm_release" "ingress_nginx" {

  name = "ingress-nginx"

  namespace = "ingress"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0"

  timeout       = 240
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
