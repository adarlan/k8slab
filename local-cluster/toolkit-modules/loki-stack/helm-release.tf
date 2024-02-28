resource "helm_release" "loki_stack" {

  name = var.release_name

  chart      = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"
  version    = "2.10.1"

  namespace        = var.namespace
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {})]

  timeout = 600
}
