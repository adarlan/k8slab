module "argo_cd" {
  source     = "./../../cluster-tools/argo-cd"
  count      = var.argo_cd != null ? 1 : 0

  node_port_http  = local.port_mappings_by_name["argocd"].node_port
  node_port_https = local.port_mappings_by_name["argocd_tls"].node_port
}

# TODO move it into the argo-cd module
data "kubernetes_secret" "argocd_initial_admin_secret" {
  count      = var.argo_cd != null ? 1 : 0
  depends_on = [module.argo_cd]
  metadata {
    namespace = "argocd"
    name      = "argocd-initial-admin-secret"
  }
}
