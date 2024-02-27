output "grafana_admin_user" {
  value     = data.kubernetes_secret.grafana_secret.data.admin-user
  sensitive = true
}

output "grafana_admin_password" {
  value     = data.kubernetes_secret.grafana_secret.data.admin-password
  sensitive = true
}
