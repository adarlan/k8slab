
resource "helm_release" "karpenter_provisioner" {
  name  = "${var.cluster_name}/karpenter-provisioner/helm-release"
  chart = "${path.module}/helm-chart"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  depends_on = [helm_release.karpenter]
}
