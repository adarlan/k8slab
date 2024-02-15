resource "helm_release" "kube_prometheus" {
  name = "kube-prometheus-stack"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.2"

  namespace        = "monitoring"
  create_namespace = true

  set {
    name  = "prometheus.service.type"
    value = "NodePort"
  }

  set {
    name  = "prometheus.service.nodePort"
    value = var.prometheus_node_port
  }

  set {
    name  = "grafana.service.type"
    value = "NodePort"
  }

  set {
    name  = "grafana.service.nodePort"
    value = var.grafana_node_port
  }

  #   dynamic "set" {
  #     for_each = var.values
  #     name     = values.key
  #     value    = values.value
  #   }

  # set {
  #   name  = "grafana.service.annotation\\.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
  #   value = "true"
  # }

  # set {
  #   name  = "prometheus.service.annotation\\.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
  #   value = "true"
  # }

}
