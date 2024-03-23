resource "local_file" "argocd_admin_password" {
  filename = "../../argocd-admin.password"
  content  = data.kubernetes_secret.argocd_admin.data["password"]
}
