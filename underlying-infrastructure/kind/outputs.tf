
output "kubeconfig" {
  value = kind_cluster.default.kubeconfig
  sensitive = true
}
