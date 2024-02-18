terraform {
  required_providers {
    helm = { source = "hashicorp/helm" }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.26.0"
    }
  }
}

# provider "helm" {
#   kubernetes {
#     host                   = var.k8s_auth_credentials.host
#     cluster_ca_certificate = var.k8s_auth_credentials.cluster_ca_certificate

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
#       command     = "aws"
#     }
#   }
# }
