terraform {
  required_providers {
    helm = { source = "hashicorp/helm" }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.26.0" # TODO move to modules
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}
