resource "local_file" "grafana_admin_password" {
  filename = "../../grafana-admin.password"
  content  = data.kubernetes_secret.grafana.data["admin-password"]
}
