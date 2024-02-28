resource "helm_release" "argo_cd" {

  name = var.release_name

  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "5.27.3"

  namespace        = var.namespace
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {
    nodePortHttp = var.node_port,
  })]

  timeout = 600
}
