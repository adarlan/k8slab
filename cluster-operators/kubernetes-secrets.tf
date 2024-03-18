data "kubernetes_secret" "namespace_manager" {

  depends_on = [helm_release.cluster_operators]

  metadata {
    name      = "namespace-manager"
    namespace = "namespace-manager"
  }
}

data "kubernetes_secret" "cluster_tools_installer" {

  depends_on = [helm_release.cluster_operators]

  metadata {
    name      = "cluster-tools-installer"
    namespace = "cluster-tools-installer"
  }
}
