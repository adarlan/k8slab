output "grafana_admin_password" {
  value     = data.kubernetes_secret.grafana.data["admin-password"]
  sensitive = true
}
