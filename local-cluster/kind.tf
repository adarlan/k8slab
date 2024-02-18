module "kind_cluster" {
  source = "./kind"

  cluster_name = var.cluster_name

  node_to_host_port_mapping = {
    "30${var.port_suffixes.argocd_http}"  = "8${var.port_suffixes.argocd_http}"
    "30${var.port_suffixes.argocd_https}" = "8${var.port_suffixes.argocd_https}"
    "30${var.port_suffixes.prometheus}"   = "8${var.port_suffixes.prometheus}"
    "30${var.port_suffixes.grafana}"      = "8${var.port_suffixes.grafana}"
  }
}
