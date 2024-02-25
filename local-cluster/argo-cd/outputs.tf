output "initial_admin_password" {
  sensitive = true
  value     = data.kubernetes_secret.argocd_initial_admin_secret.data.password
}
