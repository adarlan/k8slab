
output "argocd_port" {
  value = "8${var.port_suffixes.argocd_http}"
}

output "prometheus_port" {
  value = "8${var.port_suffixes.prometheus}"
}

output "grafana_port" {
  value = "8${var.port_suffixes.grafana}"
}
