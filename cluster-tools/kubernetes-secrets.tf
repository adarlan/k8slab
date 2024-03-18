data "kubernetes_secret" "argocd_admin" {

  depends_on = [helm_release.argo_cd]

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

data "kubernetes_secret" "grafana" {

  depends_on = [helm_release.kube_prometheus_stack]

  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = "monitoring"
  }
}
