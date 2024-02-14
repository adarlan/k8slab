terraform {
  required_providers {
    helm = { source = "hashicorp/helm" }
  }
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("./kubeconfig")
  }
}

module "kind_cluster" {
  source       = "./../../kubernetes-cluster/kind-cluster"
  cluster_name = "foo"

  node_to_host_port_mapping = {
    "30${var.port_suffixes.argocd_http}"  = "8${var.port_suffixes.argocd_http}"
    "30${var.port_suffixes.argocd_https}" = "8${var.port_suffixes.argocd_https}"
    "30${var.port_suffixes.prometheus}"   = "8${var.port_suffixes.prometheus}"
    "30${var.port_suffixes.grafana}"      = "8${var.port_suffixes.grafana}"
  }
}

module "ingress_nginx" {
  source     = "./../../ingress-nginx/ingress-nginx-for-kind"
  depends_on = [module.kind_cluster]
}

module "argocd" {
  source     = "./../../argocd/argocd-for-kind"
  depends_on = [module.kind_cluster]

  node_port_http  = "30${var.port_suffixes.argocd_http}"
  node_port_https = "30${var.port_suffixes.argocd_https}"
}

module "kube_prometheus" {
  source     = "./../../kube-prometheus"
  depends_on = [module.kind_cluster]

  prometheus_node_port = "30${var.port_suffixes.prometheus}"
  grafana_node_port    = "30${var.port_suffixes.grafana}"
}
