output "endpoint" {
  sensitive = true
  value     = kind_cluster.k8slab.endpoint
}

output "ca_key" {
  sensitive = true
  value     = data.local_file.ca_key.content
}

output "ca_certificate" {
  sensitive = true
  value     = kind_cluster.k8slab.cluster_ca_certificate
}

output "root_user_key" {
  sensitive = true
  value     = kind_cluster.k8slab.client_key
}

output "root_user_certificate" {
  sensitive = true
  value     = kind_cluster.k8slab.client_certificate
}
