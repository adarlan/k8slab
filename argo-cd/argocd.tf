
provider "helm" {
  kubernetes {
    host                   = var.host
    cluster_ca_certificate = var.cluster_ca_certificate
    client_certificate     = var.client_certificate
    client_key             = var.client_key
  }
}

provider "kubernetes" {
  host                   = var.host
  cluster_ca_certificate = var.cluster_ca_certificate
  client_certificate     = var.client_certificate
  client_key             = var.client_key
}

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

data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}
