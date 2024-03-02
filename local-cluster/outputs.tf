output "secrets" {

  sensitive = true

  value = {
    kubeconfig_path    = kind_cluster.default.kubeconfig_path
    ca_certificate     = kind_cluster.default.cluster_ca_certificate
    client_key         = kind_cluster.default.client_key
    client_certificate = kind_cluster.default.client_certificate
    endpoint           = kind_cluster.default.endpoint
  }
}

output "endpoint" {
  sensitive = true
  value = kind_cluster.default.endpoint
}

output "ca_certificate" {
  sensitive = true
  value = kind_cluster.default.cluster_ca_certificate
}
