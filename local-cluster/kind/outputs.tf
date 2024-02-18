output "kubeconfig_path" {
  value = local.kubeconfig_path
}

output "ca_certificate" {
    description = "Client verifies the server certificate with this CA cert."
    value = kind_cluster.default.cluster_ca_certificate
    sensitive = true
}

output "endpoint" {
    description = "Kubernetes APIServer endpoint."
    value = kind_cluster.default.endpoint
    sensitive = true
}
