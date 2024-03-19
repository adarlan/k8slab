data "kubernetes_secret" "namespace_provisioner" {

  depends_on = [helm_release.cluster_rbac]

  metadata {
    name      = "namespace-provisioner"
    namespace = "namespace-provisioner"
  }
}

data "kubernetes_secret" "namespace_rbac_manager" {

  depends_on = [helm_release.cluster_rbac]

  metadata {
    name      = "namespace-rbac-manager"
    namespace = "namespace-rbac-manager"
  }
}

data "kubernetes_secret" "cluster_tools_installer" {

  depends_on = [helm_release.cluster_rbac]

  metadata {
    name      = "cluster-tools-installer"
    namespace = "cluster-tools-installer"
  }
}
