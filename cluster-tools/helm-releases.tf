
resource "helm_release" "ingress_nginx" {

  name = local.ingress_nginx.release_name

  namespace        = local.ingress_nginx.namespace
  create_namespace = true

  repository = local.ingress_nginx.repo_url
  chart      = local.ingress_nginx.chart_name
  version    = local.ingress_nginx.chart_version

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file(local.ingress_nginx.values_file)
  ]
}

resource "helm_release" "loki" {

  name = local.loki.release_name

  namespace        = local.loki.namespace
  create_namespace = true

  repository = local.loki.repo_url
  chart      = local.loki.chart_name
  version    = local.loki.chart_version

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file(local.loki.values_file)
  ]
}

resource "helm_release" "promtail" {

  depends_on = [
    helm_release.loki,
  ]

  name = local.promtail.release_name

  namespace        = local.promtail.namespace
  create_namespace = true

  repository = local.promtail.repo_url
  chart      = local.promtail.chart_name
  version    = local.promtail.chart_version

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file(local.promtail.values_file)
  ]
}

resource "helm_release" "kube_prometheus_stack" {

  depends_on = [
    helm_release.ingress_nginx,
    helm_release.loki,
  ]

  name = local.kube_prometheus_stack.release_name

  namespace        = local.kube_prometheus_stack.namespace
  create_namespace = true

  repository = local.kube_prometheus_stack.repo_url
  chart      = local.kube_prometheus_stack.chart_name
  version    = local.kube_prometheus_stack.chart_version

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file(local.kube_prometheus_stack.values_file)
  ]
}

resource "helm_release" "trivy_operator" {

  name = local.trivy_operator.release_name

  namespace        = local.trivy_operator.namespace
  create_namespace = true

  repository = local.trivy_operator.repo_url
  chart      = local.trivy_operator.chart_name
  version    = local.trivy_operator.chart_version

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file(local.trivy_operator.values_file)
  ]
}

resource "helm_release" "argo_cd" {

  depends_on = [
    helm_release.ingress_nginx,
  ]

  name = local.argo_cd.release_name

  namespace        = local.argo_cd.namespace
  create_namespace = true

  repository = local.argo_cd.repo_url
  chart      = local.argo_cd.chart_name
  version    = local.argo_cd.chart_version

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file(local.argo_cd.values_file)
  ]
}
