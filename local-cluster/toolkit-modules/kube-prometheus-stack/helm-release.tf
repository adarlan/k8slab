resource "helm_release" "kube_prometheus_stack" {

  name = local.release_name

  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "56.6.2"

  namespace        = local.namespace
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {
    prometheusNodePort = var.prometheus_node_port,
    grafanaNodePort    = var.grafana_node_port,
  })]

  timeout = 600
}
