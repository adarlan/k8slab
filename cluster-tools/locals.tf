locals {

  ingress_nginx = {
    release_name  = "ingress-nginx"
    repo_name     = "ingress-nginx"
    repo_url      = "https://kubernetes.github.io/ingress-nginx"
    chart_name    = "ingress-nginx"
    chart_version = "4.10.0"
    values_file   = "${path.module}/values/ingress-nginx.values.yaml"
    namespace     = "ingress"
  }

  loki = {
    release_name  = "loki"
    repo_name     = "grafa"
    repo_url      = "https://grafana.github.io/helm-charts"
    chart_name    = "loki"
    chart_version = "5.43.3"
    values_file   = "${path.module}/values/loki.values.yaml"
    namespace     = "monitoring"
  }

  promtail = {
    release_name  = "promtail"
    repo_name     = "grafana"
    repo_url      = "https://grafana.github.io/helm-charts"
    chart_name    = "promtail"
    chart_version = "6.15.5"
    values_file   = "${path.module}/values/promtail.values.yaml"
    namespace     = "monitoring"
  }

  kube_prometheus_stack = {
    release_name  = "kube-prometheus-stack"
    repo_name     = "prometheus-community"
    repo_url      = "https://prometheus-community.github.io/helm-charts"
    chart_name    = "kube-prometheus-stack"
    chart_version = "56.6.2"
    values_file   = "${path.module}/values/kube-prometheus-stack.values.yaml"
    namespace     = "monitoring"
  }

  trivy_operator = {
    release_name  = "trivy-operator"
    repo_name     = "aquasecurity"
    repo_url      = "https://aquasecurity.github.io/helm-charts"
    chart_name    = "trivy-operator"
    chart_version = "0.20.6"
    values_file   = "${path.module}/values/trivy-operator.values.yaml"
    namespace     = "trivy"
  }

  argo_cd = {
    release_name  = "argo-cd"
    repo_name     = "argo"
    repo_url      = "https://argoproj.github.io/argo-helm"
    chart_name    = "argo-cd"
    chart_version = "6.4.1"
    values_file   = "${path.module}/values/argo-cd.values.yaml"
    namespace     = "argocd"
  }
}
