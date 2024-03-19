resource "helm_release" "namespace_provisioning" {

  name  = "namespace-provisioning"
  chart = path.module

  namespace        = "namespace-provisioning"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
