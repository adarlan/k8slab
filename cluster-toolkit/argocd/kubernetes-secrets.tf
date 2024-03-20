data "kubernetes_secret" "argocd_admin" {

  depends_on = [helm_release.argo_cd]

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}
