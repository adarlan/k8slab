data "kubernetes_secret" "grafana" {

  depends_on = [helm_release.kube_prometheus_stack]

  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = "monitoring"
  }
}
