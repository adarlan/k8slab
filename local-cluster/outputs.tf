
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
      url = "https://localhost:8${var.port_suffixes.argocd_http}"
      username = "admin"
      password = data.kubernetes_secret.argocd_initial_admin_secret.data.password
    }

    prometheus = {
      url = "http://localhost:8${var.port_suffixes.prometheus}"
    }

    grafana = {
      url = "http://localhost:8${var.port_suffixes.grafana}"
      username = data.kubernetes_secret.kube_prometheus_stack_grafana.data.admin-user
      password = data.kubernetes_secret.kube_prometheus_stack_grafana.data.admin-password
    }
  }
}
