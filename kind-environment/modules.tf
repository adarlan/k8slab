
module "kind-cluster" {
  source       = "./../kind-cluster"
  cluster_name = "foo"
}

module "kind-nginx-ingress-controller" {
  source = "./../kind-nginx-ingress-controller"
  cluster_credentials = {
    host                   = module.kind-cluster.endpoint
    cluster_ca_certificate = module.kind-cluster.cluster_ca_certificate
    client_certificate     = module.kind-cluster.client_certificate
    client_key             = module.kind-cluster.client_key
  }
}

module "argo-cd" {
  source                 = "./../argo-cd"
  host                   = module.kind-cluster.endpoint
  cluster_ca_certificate = module.kind-cluster.cluster_ca_certificate
  client_certificate     = module.kind-cluster.client_certificate
  client_key             = module.kind-cluster.client_key
}

module "kube-prometheus" {
  source                 = "./../kube-prometheus"
  host                   = module.kind-cluster.endpoint
  cluster_ca_certificate = module.kind-cluster.cluster_ca_certificate
  client_certificate     = module.kind-cluster.client_certificate
  client_key             = module.kind-cluster.client_key
}
