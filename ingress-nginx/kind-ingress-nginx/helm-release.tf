
resource "helm_release" "kind_nginx_ingress_controller" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.1"

  namespace        = "ingress-nginx"
  create_namespace = true

  values = [file("${path.module}/helm-values.yaml")]
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl --kubeconfig ${pathexpand("./kubeconfig")} wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
  }

  depends_on = [helm_release.kind_nginx_ingress_controller]
}
