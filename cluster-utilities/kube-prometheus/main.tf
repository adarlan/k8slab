terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "kube_prometheus" {
  name       = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace = "monitoring"
  create_namespace = true
  version = "48.6.0"

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
