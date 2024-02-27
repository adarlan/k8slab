data "kubernetes_secret" "grafana_secret" {

  depends_on = [helm_release.kube_prometheus_stack]

  metadata {
    namespace = local.namespace
    name      = "${local.release_name}-grafana"
  }
}
