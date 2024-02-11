
resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  # version    = "5.27.3"
  version = "4.9.7"

  namespace        = "argocd"
  create_namespace = true

  # values = [templatefile("./values.yaml", {})]
  # values = [
  #     file("argocd/application.yaml")
  # ]

  # timeout = "1200"
}
