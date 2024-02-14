resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.27.3"

  namespace        = "argocd"
  create_namespace = true

  values = [ templatefile("${path.module}/helm-values.yaml", {}) ]
}
