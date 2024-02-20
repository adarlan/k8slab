port_mappings = [
  {
    name = "ingress",
    host_port = "80",
    node_port = "80"
  },
  {
    name = "ingress_tls",
    host_port = "443",
    node_port = "443"
  },
  {
    name = "argocd",
    host_port = "8011",
    node_port = "30011"
  },
  {
    name = "argocd_tls",
    host_port = "8012",
    node_port = "30012"
  },
  {
    name = "prometheus",
    host_port = "8065",
    node_port = "30065"
  },
  {
    name = "grafana",
    host_port = "8066",
    node_port = "30066"
  },
]
