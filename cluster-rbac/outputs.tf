output "namespace_provisioning_token" {
  value     = data.kubernetes_secret.namespace_provisioning.data["token"]
  sensitive = true
}

output "namespace_rbac_token" {
  value     = data.kubernetes_secret.namespace_rbac.data["token"]
  sensitive = true
}

output "cluster_tools_token" {
  value     = data.kubernetes_secret.cluster_tools.data["token"]
  sensitive = true
}
