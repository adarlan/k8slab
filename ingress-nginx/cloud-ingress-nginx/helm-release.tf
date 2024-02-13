
resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.1"

  namespace        = "ingress-nginx"
  create_namespace = true

  #   set {
  #     name = "controller.replicaCount"
  #     value = "2"
  #   }

  #   set {
  #     name = "controller.nodeSelector.\"beta\\.kubernetes\\.io/os\""
  #     value = "linux"
  #   }

  #   set {
  #     name = "defaultBackend.nodeSelector.\"beta\\.kubernetes\\.io/os\""
  #     value = "linux"
  #   }

  #   set {
  #     name = "controller.admissionWebhooks.patch.nodeSelector.\"beta\\.kubernetes\\.io/os\""
  #     value = "linux"
  #   }
}
