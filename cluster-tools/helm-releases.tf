resource "helm_release" "networking_stack" {

  name = "networking-stack"

  namespace        = "networking"
  create_namespace = true

  chart = "${path.module}/networking-stack"

  timeout       = 600
  wait          = true
  wait_for_jobs = true

  values = [file("${path.module}/networking-stack/values.yaml")]
}

resource "helm_release" "argocd_stack" {

  name = "argocd-stack"

  namespace        = "argocd"
  create_namespace = true

  chart = "${path.module}/argocd-stack"

  timeout       = 600
  wait          = true
  wait_for_jobs = true

  values = [file("${path.module}/argocd-stack/values.yaml")]
}

resource "helm_release" "security_stack" {

  name = "security-stack"

  namespace        = "security"
  create_namespace = true

  chart = "${path.module}/security-stack"

  timeout       = 600
  wait          = true
  wait_for_jobs = true

  values = [file("${path.module}/security-stack/values.yaml")]
}

resource "helm_release" "monitoring_stack" {

  name = "monitoring-stack"

  namespace        = "monitoring"
  create_namespace = true

  chart = "${path.module}/monitoring-stack"

  timeout       = 600
  wait          = true
  wait_for_jobs = true

  values = [file("${path.module}/monitoring-stack/values.yaml")]
}
