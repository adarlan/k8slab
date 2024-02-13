
module "kind_cluster" {
  source       = "./../../k8s-cluster/kind-cluster"
  cluster_name = "foo"
}

module "ingress_nginx" {
  source = "./../../ingress-nginx/kind-ingress-nginx"

  depends_on = [
    module.kind_cluster
  ]
}

module "argo_cd" {
  source = "./../../argo-cd"

  depends_on = [
    module.kind_cluster,
    module.ingress_nginx
  ]
}

module "argocd_apps" {
  source = "./../../argocd-apps"

  depends_on = [
    module.kind_cluster,
    module.argo_cd
  ]
}

# module "kube_prometheus" {
#   source                 = "./../../kube-prometheus"
#   host                   = module.kind_cluster.endpoint
#   cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
#   client_certificate     = module.kind_cluster.client_certificate
#   client_key             = module.kind_cluster.client_key
# }
