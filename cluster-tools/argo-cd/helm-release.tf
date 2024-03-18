resource "helm_release" "argo_cd" {

  name = "argo-cd"

  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.4.1"

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
