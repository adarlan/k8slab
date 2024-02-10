
provider "helm" {
  kubernetes {
    host                   = var.k8s_auth_credentials.host
    cluster_ca_certificate = var.k8s_auth_credentials.cluster_ca_certificate

    # TODO is it possible to use only auth credentials instead of the exec plugin?
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}
