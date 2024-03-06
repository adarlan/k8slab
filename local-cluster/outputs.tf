output "endpoint" {
  sensitive = true
  value = kind_cluster.default.endpoint
}

output "ca_certificate" {
  sensitive = true
  value = kind_cluster.default.cluster_ca_certificate
}

output "root_user_key" {
  sensitive = true
  value = kind_cluster.default.client_key
}

output "root_user_certificate" {
  sensitive = true
  value = kind_cluster.default.client_certificate
}
