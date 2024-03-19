resource "helm_release" "namespace_rbac" {

  name  = "namespace-rbac"
  chart = path.module

  namespace        = "namespace-rbac"

  values = [
    file("${path.module}/values.yaml")
  ]
}
