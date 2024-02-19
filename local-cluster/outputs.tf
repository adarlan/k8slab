output "cluster_name" {
  value = "kind-${var.cluster_name}"
}

output "cluster_endpoint" {
  value     = module.kind_cluster.endpoint
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.kind_cluster.ca_certificate
  sensitive = true
}

output "client_key" {
  value     = module.kind_cluster.client_key
  sensitive = true
}

output "client_certificate" {
  value     = module.kind_cluster.client_certificate
  sensitive = true
}

output "argocd_port" {
  value = "8${var.port_suffixes.argocd_http}"
}

output "prometheus_port" {
  value = "8${var.port_suffixes.prometheus}"
}

output "grafana_port" {
  value = "8${var.port_suffixes.grafana}"
}

output "login_info" {
  sensitive = true
  value = {

    argocd = {
      url      = "https://localhost:8${var.port_suffixes.argocd_http}"
      username = "admin"
      password = data.kubernetes_secret.argocd_initial_admin_secret.data.password
    }

    prometheus = {
      url = "http://localhost:8${var.port_suffixes.prometheus}"
    }

    grafana = {
      url      = "http://localhost:8${var.port_suffixes.grafana}"
      username = data.kubernetes_secret.kube_prometheus_stack_grafana.data.admin-user
      password = data.kubernetes_secret.kube_prometheus_stack_grafana.data.admin-password
    }
  }
}
