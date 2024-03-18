output "namespace_manager_token" {
  value     = data.kubernetes_secret.namespace_manager.data["token"]
  sensitive = true
}

output "cluster_tools_installer_token" {
  value     = data.kubernetes_secret.cluster_tools_installer.data["token"]
  sensitive = true
}
