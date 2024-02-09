
output "kubeconfig" {
  value = module.kind.kubeconfig
  sensitive = true
}

output "argocd_initial_admin_password" {
  value = module.argo-cd.initial_admin_password
  sensitive = true
}
