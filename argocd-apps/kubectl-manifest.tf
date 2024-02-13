
resource "kubectl_manifest" "argocd_apps" {
  yaml_body = file(pathexpand("${path.module}/argocd-apps.yaml"))

  depends_on = [
    module.kind-cluster,
    module.argo-cd
  ]
}
