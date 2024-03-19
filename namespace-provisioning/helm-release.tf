resource "helm_release" "namespace_provisioning" {

  name  = "namespace-provisioning"
  chart = path.module

  namespace        = "namespace-provisioning"

  values = [
    file("${path.module}/values.yaml")
  ]
}
