resource "helm_release" "cluster_rbac" {

  name  = "cluster-rbac"
  chart = path.module

  namespace        = "cluster-rbac"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
