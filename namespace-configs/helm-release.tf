resource "helm_release" "namespace_configs" {

  name  = "namespace-configs"
  chart = path.module

  namespace        = "namespace-configs"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
