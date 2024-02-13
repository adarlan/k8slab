
resource "kubectl_manifest" "argocd_apps" {
  yaml_body = file("${path.module}/argocd-apps.yaml")
}
