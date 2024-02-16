module "ingress_nginx" {
  source     = "./../cluster-tools/ingress-nginx"
  depends_on = [module.kind_cluster]
}

module "argo_cd" {
  source     = "./../cluster-tools/argo-cd"
  depends_on = [module.kind_cluster]

  node_port_http  = "30${var.port_suffixes.argocd_http}"
  node_port_https = "30${var.port_suffixes.argocd_https}"
}

module "kube_prometheus_stack" {
  source     = "./../cluster-tools/kube-prometheus-stack"
  depends_on = [module.kind_cluster]

  prometheus_node_port = "30${var.port_suffixes.prometheus}"
  grafana_node_port    = "30${var.port_suffixes.grafana}"
}

module "trivy_operator" {
  source     = "./../cluster-tools/trivy-operator"
  depends_on = [module.kind_cluster]
}
