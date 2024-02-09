
output "kubeconfig" {
  value = kind_cluster.default.kubeconfig
  sensitive = true
}

output "endpoint" {
  value = kind_cluster.default.endpoint
  sensitive = true
}

output "cluster_ca_certificate" {
  value = kind_cluster.default.cluster_ca_certificate
  sensitive = true
}

output "client_certificate" {
  value = kind_cluster.default.client_certificate
  sensitive = true
}

output "client_key" {
  value = kind_cluster.default.client_key
  sensitive = true
}
