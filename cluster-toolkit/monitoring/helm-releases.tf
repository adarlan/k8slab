resource "helm_release" "loki" {

  name = "loki"

  namespace = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "5.43.3"

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/values-loki.yaml")
  ]
}

resource "helm_release" "promtail" {

  depends_on = [
    helm_release.loki
  ]

  name = "promtail"

  namespace = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.15.5"

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/values-promtail.yaml")
  ]
}

resource "helm_release" "kube_prometheus_stack" {

  depends_on = [
    helm_release.loki,
    helm_release.promtail
  ]

  name = "kube-prometheus-stack"

  namespace = "monitoring"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.2"

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/values-kube-prometheus-stack.yaml")
  ]
}
