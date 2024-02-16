resource "helm_release" "trivy_operator" {
  name       = "trivy-operator"

  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "trivy-operator"
  # TODO version

  namespace = "trivy"
  create_namespace = true

  values = [file("${path.module}/values.yaml")]
}
