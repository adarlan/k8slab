
provider "helm" {
  kubernetes {
    config_path = pathexpand("./kubeconfig")
  }
}

provider "kubectl" {
  config_path = pathexpand("./kubeconfig")
}
