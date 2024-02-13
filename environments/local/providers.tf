terraform {
  required_providers {
    helm = { # Not used directly by this module, but configuration is required
      source  = "hashicorp/helm"
      # version = "2.12.1"
    }

    kubectl = { # Not used directly by this module, but configuration is required
      source = "gavinbunney/kubectl"
      # version = "1.14.0"
    }

    # kind = { # Not used directly by this module and configuration is not required
    #   source  = "tehcyx/kind"
    #   version = "0.2.1"
    # }

    null = { # Used directly by this module
      source = "hashicorp/null"
      version = "3.2.2"
    }
  }

  # TODO What if this module uses two other modules that use different versions of the same provider?
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("./kubeconfig")
  }
}

provider "kubectl" {
  config_path = pathexpand("./kubeconfig")
}
