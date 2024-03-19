output "namespace_provisioner_token" {
  value     = data.kubernetes_secret.namespace_provisioner.data["token"]
  sensitive = true
}

output "namespace_rbac_manager_token" {
  value     = data.kubernetes_secret.namespace_rbac_manager.data["token"]
  sensitive = true
}

output "cluster_tools_installer_token" {
  value     = data.kubernetes_secret.cluster_tools_installer.data["token"]
  sensitive = true
}
