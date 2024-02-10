provider "helm" {
  kubernetes {
    host                   = var.host
    cluster_ca_certificate = var.cluster_ca_certificate
    client_certificate     = var.client_certificate
    client_key             = var.client_key
  }
}

resource "helm_release" "kube_prometheus" {
  name = "prometheus-community"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "48.6.0"

  namespace        = "monitoring"
  create_namespace = true


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
  # set {
  #   name  = "prometheus.service.type"
  #   value = "LoadBalancer"
  # }

  # set {
  #   name  = "grafana.service.type"
  #   value = "LoadBalancer"
  # }

}
