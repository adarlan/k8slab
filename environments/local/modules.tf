terraform {
  required_providers {
    helm = { source = "hashicorp/helm" }
  }
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("./kubeconfig")
  }
}

module "kind_cluster" {
  source       = "./../../kubernetes-cluster/kind-cluster"
  cluster_name = "foo"
}

module "ingress_nginx" {
  source     = "./../../ingress-nginx/ingress-nginx-for-kind"
  depends_on = [module.kind_cluster]
}

module "argocd" {
  source     = "./../../argocd/argocd-for-kind"
  depends_on = [module.kind_cluster]
}

# module "kube_prometheus" {
#   source                 = "./../../kube-prometheus"
#   host                   = module.kind_cluster.endpoint
#   cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
#   client_certificate     = module.kind_cluster.client_certificate
#   client_key             = module.kind_cluster.client_key
# }

# resource "null_resource" "login" {
#   triggers = { key = uuid() }
#   provisioner "local-exec" { command = file("./login.sh") }
#   depends_on = [module.argocd_apps]
# }
