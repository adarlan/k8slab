resource "helm_release" "cluster_operators" {

  name  = "cluster-operators"
  chart = path.module

  namespace        = "cluster-operators"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
