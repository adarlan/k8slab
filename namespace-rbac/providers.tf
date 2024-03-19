terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = file(var.cluster_ca_certificate)
    token                  = file(var.namespace_rbac_manager_token)
  }
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = file(var.cluster_ca_certificate)
  token                  = file(var.namespace_rbac_manager_token)
}
