provider "helm" {

  # DOC https://registry.terraform.io/providers/hashicorp/helm/latest/docs

  kubernetes {
    host                   = "CLUSTER_ENDPOINT"
    cluster_ca_certificate = "CLUSTER_CA_CERTIFICATE"

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", "CLUSTER_NAME"]
      command     = "aws"
    }
  }
}
