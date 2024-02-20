module "kube_prometheus_stack" {
  source     = "./../../cluster-tools/kube-prometheus-stack"
  count      = var.kube_prometheus_stack != null ? 1 : 0

  prometheus_node_port = local.port_mappings_by_name["prometheus"].node_port
  grafana_node_port    = local.port_mappings_by_name["grafana"].node_port
}

# TODO move to module
data "kubernetes_secret" "kube_prometheus_stack_grafana" {
  count      = var.kube_prometheus_stack != null ? 1 : 0
  depends_on = [module.kube_prometheus_stack]
  metadata {
    namespace = "monitoring"
    name      = "kube-prometheus-stack-grafana"
  }
}
