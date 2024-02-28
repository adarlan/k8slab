data "kubernetes_secret" "initial_admin_secret" {

  depends_on = [helm_release.argo_cd]

  metadata {
    namespace = var.namespace
    name      = "argocd-initial-admin-secret" # TODO is 'argocd' prefix the namespace?
  }
}
