output "secrets" {

  sensitive = true

  value = merge({},

    var.modules.argo_cd.enabled ? {

      argocd = {

        url      = "http://localhost:${var.port_mappings_by_name.argocd.host_port}"
        username = "admin"
        password = module.argo_cd[0].initial_admin_password
        host     = "localhost"
        port     = var.port_mappings_by_name.argocd.host_port
      }
    } : {},

    var.modules.kube_prometheus_stack.enabled ? {

      prometheus = {

        url = "http://localhost:${var.port_mappings_by_name.prometheus.host_port}"
      }

      kubeprometheus_grafana = {

        url      = "http://localhost:${var.port_mappings_by_name.kubeprometheus_grafana.host_port}"
        username = module.kube_prometheus_stack[0].grafana_admin_user
        password = module.kube_prometheus_stack[0].grafana_admin_password
      }
    } : {},

    var.modules.loki_stack.enabled ? {

      loki_grafana = {

        url      = "http://localhost:${var.port_mappings_by_name.loki_grafana.host_port}"
        username = module.loki_stack[0].grafana_admin_user
        password = module.loki_stack[0].grafana_admin_password
      }
    } : {},

  )
}
