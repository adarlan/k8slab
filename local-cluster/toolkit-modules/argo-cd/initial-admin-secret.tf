data "kubernetes_secret" "initial_admin_secret" {

  depends_on = [helm_release.argo_cd]

  metadata {
    namespace = "argocd"
    name      = "argocd-initial-admin-secret"
  }
}
