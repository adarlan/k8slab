data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    namespace = "argocd"
    name      = "argocd-initial-admin-secret"
  }
  depends_on = [module.argo_cd]
}

data "kubernetes_secret" "kube_prometheus_stack_grafana" {
  metadata {
    namespace = "monitoring"
    name      = "kube-prometheus-stack-grafana"
  }
  depends_on = [module.kube_prometheus_stack]
}
