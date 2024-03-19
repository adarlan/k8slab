data "kubernetes_secret" "namespace_provisioning" {

  depends_on = [helm_release.cluster_rbac]

  metadata {
    name      = "namespace-provisioning"
    namespace = "namespace-provisioning"
  }
}

data "kubernetes_secret" "namespace_rbac" {

  depends_on = [helm_release.cluster_rbac]

  metadata {
    name      = "namespace-rbac"
    namespace = "namespace-rbac"
  }
}

data "kubernetes_secret" "cluster_toolkit" {

  depends_on = [helm_release.cluster_rbac]

  metadata {
    name      = "cluster-toolkit"
    namespace = "cluster-toolkit"
  }
}
