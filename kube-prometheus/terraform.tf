
terraform {
  required_version = "~> 1.7"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}
