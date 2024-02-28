data "kubernetes_secret" "grafana_secret" {

  depends_on = [helm_release.kube_prometheus_stack]

  metadata {
    namespace = var.namespace
    name      = "${var.release_name}-grafana"
  }
}
