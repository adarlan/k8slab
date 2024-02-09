
module "kind" {
  source = "./../../underlying-infrastructure/kind"
  cluster_name = "foo"
}

output "kubeconfig" {
  value = module.kind.kubeconfig
  sensitive = true
}
