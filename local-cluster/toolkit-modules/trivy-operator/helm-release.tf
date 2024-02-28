resource "helm_release" "trivy_operator" {

  name = var.release_name

  chart      = "trivy-operator"
  repository = "https://aquasecurity.github.io/helm-charts/"
  version    = "0.20.6"

  namespace        = var.namespace
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {})]

  timeout = 600
}
