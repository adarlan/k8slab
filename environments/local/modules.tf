
module "kind-cluster" {
  source       = "./../../k8s-cluster/kind-cluster"
  cluster_name = "foo"
}

module "ingress-nginx" {
  source = "./../../ingress-nginx/kind-ingress-nginx"
  
  depends_on = [
    module.kind-cluster
  ]
}

module "argo-cd" {
  source = "./../../argo-cd"
  
  depends_on = [
    module.kind-cluster,
    module.ingress-nginx
  ]
}

# module "kube-prometheus" {
#   source                 = "./../../kube-prometheus"
#   host                   = module.kind-cluster.endpoint
#   cluster_ca_certificate = module.kind-cluster.cluster_ca_certificate
#   client_certificate     = module.kind-cluster.client_certificate
#   client_key             = module.kind-cluster.client_key
# }
