
provider "helm" {
  kubernetes {
    host                   = var.cluster_credentials.host
    cluster_ca_certificate = var.cluster_credentials.cluster_ca_certificate
    client_certificate = var.cluster_credentials.client_certificate
    client_key = var.cluster_credentials.client_key
  }
}
