output "cluster_name" {
  value = var.cluster_name
}

output "kubeconfig_path" {
  value = kind_cluster.default.kubeconfig_path
}

output "ca_certificate" {
  description = "Client verifies the server certificate with this CA cert."
  value       = kind_cluster.default.cluster_ca_certificate
  sensitive   = true
}

output "client_key" {
  value     = kind_cluster.default.client_key
  sensitive = true
}

output "client_certificate" {
  value     = kind_cluster.default.client_certificate
  sensitive = true
}

output "endpoint" {
  description = "Kubernetes APIServer endpoint."
  value       = kind_cluster.default.endpoint
  sensitive   = true
}
