
module "kind" {
  source = "./../kind-cluster"
  cluster_name = "foo"
}

module "argo-cd" {
  source = "./../argo-cd"
  host = module.kind.endpoint
  cluster_ca_certificate = module.kind.cluster_ca_certificate
  client_certificate = module.kind.client_certificate
  client_key = module.kind.client_key
}

module "kube-prometheus" {
  source = "./../kube-prometheus"
  host = module.kind.endpoint
  cluster_ca_certificate = module.kind.cluster_ca_certificate
  client_certificate = module.kind.client_certificate
  client_key = module.kind.client_key
}
