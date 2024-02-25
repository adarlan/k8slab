data "kubernetes_secret" "argocd_initial_admin_secret" {
  depends_on = [helm_release.argo_cd]
  metadata {
    namespace = "argocd"
    name      = "argocd-initial-admin-secret"
  }
}
