resource "helm_release" "kube_prometheus_stack" {
  name    = "kube-prometheus-stack"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.2"

  namespace        = "monitoring"
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {
    prometheusNodePort = var.prometheus_node_port,
    grafanaNodePort    = var.grafana_node_port,
  })]
}
