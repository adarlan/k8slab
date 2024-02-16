resource "helm_release" "trivy_operator" {
  name       = "trivy-operator"

  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "trivy-operator"
  version    = "0.20.6"

  namespace = "trivy"
  create_namespace = true

  values = [file("${path.module}/values.yaml")]
}
