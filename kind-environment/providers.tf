
provider "helm" {
  kubernetes {
    config_path = pathexpand("./kubeconfig")
  }
}
