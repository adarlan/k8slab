output "grafana_admin_user" {
    value = data.kubernetes_secret.kube_prometheus_stack_grafana.data.admin-user
    sensitive = true
}

output "grafana_admin_password" {
    value = data.kubernetes_secret.kube_prometheus_stack_grafana.data.admin-password
    sensitive = true
}
