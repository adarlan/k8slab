resource "helm_release" "trivy_operator" {

  name = "trivy-operator"

  chart      = "trivy-operator"
  repository = "https://aquasecurity.github.io/helm-charts/"
  version    = "0.20.6"

  namespace        = "trivy"
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {})]

  timeout = 600
}
