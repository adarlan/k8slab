resource "helm_release" "trivy_operator" {

  name = "trivy-operator"

  namespace        = "trivy"
  create_namespace = true

  repository = "https://aquasecurity.github.io/helm-charts"
  chart      = "trivy-operator"
  version    = "0.20.6"

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
