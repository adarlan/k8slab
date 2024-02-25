
resource "helm_release" "karpenter_controller" {
  name = "${var.cluster_name}/karpenter-controller"

  namespace        = "karpenter"
  create_namespace = true

  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.16.3"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller_role.arn
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "clusterEndpoint"
    value = var.k8s_auth_credentials.host
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter_controller_instance_profile.name
  }

  # TODO depends_on private_node_group
  # but this dependency is already implicit bu modules dependency
}
