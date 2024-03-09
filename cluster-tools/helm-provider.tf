provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = file(var.cluster_ca_certificate)
    token                  = file(var.service_account_token)
  }
}
