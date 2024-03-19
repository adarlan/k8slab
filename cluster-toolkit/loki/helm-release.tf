resource "helm_release" "loki" {

  name = "loki"

  namespace        = "monitoring"
  create_namespace = false

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "5.43.3"

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
