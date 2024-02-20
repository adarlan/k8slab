output "port_mappings_by_name" {
  value = local.port_mappings_by_name
}

output "login_info" {
  sensitive = true

  value = merge(

    var.argo_cd == null ? {} : {
      argocd = {
        url      = "https://localhost:${local.port_mappings_by_name["argocd"].host_port}"
        username = "admin"
        password = data.kubernetes_secret.argocd_initial_admin_secret[0].data.password
      }
    },

    var.kube_prometheus_stack == null ? {} : {

      prometheus = {
        url = "http://localhost:${local.port_mappings_by_name["prometheus"].host_port}"
      }

      grafana = {
        url      = "http://localhost:${local.port_mappings_by_name["grafana"].host_port}"
        username = data.kubernetes_secret.kube_prometheus_stack_grafana[0].data.admin-user
        password = data.kubernetes_secret.kube_prometheus_stack_grafana[0].data.admin-password
      }
    },
  )
}
