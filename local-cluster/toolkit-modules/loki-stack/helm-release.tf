resource "helm_release" "loki_stack" {

  name = local.release_name

  chart      = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"
  version    = "2.10.1"

  namespace        = local.namespace
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {})]

  timeout = 600
}
