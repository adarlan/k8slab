output "namespace_provisioning_token" {
  value     = data.kubernetes_secret.namespace_provisioning.data["token"]
  sensitive = true
}

output "namespace_rbac_token" {
  value     = data.kubernetes_secret.namespace_rbac.data["token"]
  sensitive = true
}

output "cluster_toolkit_token" {
  value     = data.kubernetes_secret.cluster_toolkit.data["token"]
  sensitive = true
}
