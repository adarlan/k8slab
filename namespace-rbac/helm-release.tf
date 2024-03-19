resource "helm_release" "namespace_rbac" {

  name  = "namespace-rbac"
  chart = path.module

  namespace        = "namespace-rbac"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
