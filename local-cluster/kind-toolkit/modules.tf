module "ingress_nginx" {

  source = "./../toolkit-modules/ingress-nginx"
  count  = var.modules.ingress_nginx.enabled ? 1 : 0

  release_name = var.modules.ingress_nginx.release_name
  namespace    = var.modules.ingress_nginx.namespace
}

module "argo_cd" {

  source = "./../toolkit-modules/argo-cd"
  count  = var.modules.argo_cd.enabled ? 1 : 0

  release_name = var.modules.argo_cd.release_name
  namespace    = var.modules.argo_cd.namespace

  depends_on = [module.ingress_nginx]

  node_port = var.port_mappings_by_name["argocd"].node_port
}

module "kube_prometheus_stack" {

  source = "./../toolkit-modules/kube-prometheus-stack"
  count  = var.modules.kube_prometheus_stack.enabled ? 1 : 0

  release_name = var.modules.kube_prometheus_stack.release_name
  namespace    = var.modules.kube_prometheus_stack.namespace

  depends_on = [module.ingress_nginx]

  prometheus_node_port = var.port_mappings_by_name["prometheus"].node_port
  grafana_node_port    = var.port_mappings_by_name["kubeprometheus_grafana"].node_port
}

module "loki_stack" {

  source = "./../toolkit-modules/loki-stack"
  count  = var.modules.loki_stack.enabled ? 1 : 0

  release_name = var.modules.loki_stack.release_name
  namespace    = var.modules.loki_stack.namespace

  depends_on = [module.ingress_nginx]

  # TODO grafana_node_port = var.port_mappings_by_name["loki_grafana"].node_port
}

module "trivy_operator" {

  source = "./../toolkit-modules/trivy-operator"
  count  = var.modules.trivy_operator.enabled ? 1 : 0

  release_name = var.modules.trivy_operator.release_name
  namespace    = var.modules.trivy_operator.namespace
}
