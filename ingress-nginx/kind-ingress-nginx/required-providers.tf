
terraform {
  required_providers {

    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }

  }
}
