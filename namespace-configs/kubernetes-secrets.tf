data "kubernetes_secret" "argocd_application_deployer" {

  depends_on = [helm_release.namespace_configs]

  metadata {
    name      = "application-deployer"
    namespace = "argocd"
  }
}
