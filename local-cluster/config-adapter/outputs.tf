output "kind_cluster_config" {
  value = {
    worker_node_count          = var.worker_node_count
    controll_plane_node_labels = local.controll_plane_node_labels
    port_mappings              = local.port_mappings
  }
}

output "kind_toolkit_config" {
  # TODO => cluster_toolkit_config
  value = {
    modules               = local.modules
    port_mappings_by_name = local.port_mappings_by_name
  }
}

output "application_deployment_config" {
  value = {
    ingress = {
      enabled = local.modules.ingress_nginx.enabled
      # TODO domain?
      # TODO controller? (ingress-nginx)
    }
    serviceMonitor = {
      enabled                       = true
      prometheusOperatorReleaseName = "kube-prometheus-stack"
    }
  }
}
