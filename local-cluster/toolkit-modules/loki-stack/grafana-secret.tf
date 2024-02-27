data "kubernetes_secret" "grafana_secret" {

  depends_on = [helm_release.loki_stack]

  metadata {
    namespace = local.namespace
    name      = "${local.release_name}-grafana"
  }
}
