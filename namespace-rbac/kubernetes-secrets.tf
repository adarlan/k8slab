data "kubernetes_secret" "argocd_application_deployer" {

  depends_on = [helm_release.namespace_rbac]

  metadata {
    name      = "application-deployer"
    namespace = "argocd"
  }
}
