locals {

  # controll_plane_node_labels = try(var.ingress_nginx.enabled, false) ? "ingress-ready=true" : ""
  controll_plane_node_labels = "ingress-ready=true"

  modules = {
    for m in [
      {
        name    = "ingress_nginx",
        enabled = try(var.ingress_nginx.enabled, false)
      },
      {
        name    = "argo_cd",
        enabled = try(var.argo_cd.enabled, false)
      },
      {
        name    = "kube_prometheus_stack",
        enabled = try(var.kube_prometheus_stack.enabled, false)
      },
      {
        name    = "loki_stack",
        enabled = try(var.loki_stack.enabled, false)
      },
      {
        name    = "trivy_operator",
        enabled = try(var.trivy_operator.enabled, false)
      },
    ] : m.name => m
  }

  port_mappings = [
    {
      name      = "ingres"
      host_port = 80
      node_port = 80
    },
    {
      name      = "ingres_tls"
      host_port = 443
      node_port = 443
    },
    {
      name      = "argocd"
      host_port = 8001
      node_port = 30001
    },
    {
      name      = "prometheus"
      host_port = 8002
      node_port = 30002
    },
    {
      name      = "kubeprometheus_grafana"
      host_port = 8003
      node_port = 30003
    },
    {
      name      = "loki_grafana"
      host_port = 8004
      node_port = 30004
    },
  ]

  port_mappings_by_name = {
    for m in local.port_mappings : m.name => {
      host_port = m.host_port
      node_port = m.node_port
    }
  }
}
