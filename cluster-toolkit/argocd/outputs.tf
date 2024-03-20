output "argocd_admin_password" {
  value     = data.kubernetes_secret.argocd_admin.data["password"]
  sensitive = true
}
