terraform {
  required_providers {
    helm = { source = "hashicorp/helm" }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.26.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = module.kind_cluster.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = module.kind_cluster.kubeconfig_path
}
