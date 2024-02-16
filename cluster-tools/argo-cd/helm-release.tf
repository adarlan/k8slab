resource "helm_release" "argo_cd" {
  name = "argo-cd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.27.3"

  namespace        = "argocd"
  create_namespace = true

  values = [ templatefile("${path.module}/helm-values.yaml", {
    node_port_http  = var.node_port_http,
    node_port_https = var.node_port_https
  }) ]
}
