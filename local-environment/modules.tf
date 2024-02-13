
module "kind-cluster" {
  source       = "./../kind-cluster"
  cluster_name = "foo"
}

module "kind-nginx-ingress-controller" {
  source = "./../kind-nginx-ingress-controller"
  
  depends_on = [
    module.kind-cluster
  ]
}

module "argo-cd" {
  source = "./../argo-cd"
  
  depends_on = [
    module.kind-cluster,
    module.kind-nginx-ingress-controller
  ]
}

# module "kube-prometheus" {
#   source                 = "./../kube-prometheus"
#   host                   = module.kind-cluster.endpoint
#   cluster_ca_certificate = module.kind-cluster.cluster_ca_certificate
#   client_certificate     = module.kind-cluster.client_certificate
#   client_key             = module.kind-cluster.client_key
# }
