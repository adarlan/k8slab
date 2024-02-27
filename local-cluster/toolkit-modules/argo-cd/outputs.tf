output "initial_admin_password" {
  sensitive = true
  value     = data.kubernetes_secret.initial_admin_secret.data.password
}
