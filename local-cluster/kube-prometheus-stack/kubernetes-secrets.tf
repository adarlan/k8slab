data "kubernetes_secret" "kube_prometheus_stack_grafana" {
  depends_on = [helm_release.kube_prometheus_stack]

  metadata {
    namespace = "monitoring"
    name      = "kube-prometheus-stack-grafana"
  }
}
