
resource "aws_iam_instance_profile" "karpenter_controller_instance_profile" {
  name = "${var.cluster_name}/karpenter-controller-instance-profile"
  role = var.node_group_role_name
}
# Using the node-group-role instead of creating a dedicated one
# because if you use a dedicated role for Karpenter,
# you will need to manually edit the aws-auth configmap to add the arn of the Karpenter role
# kubectl edit configmap aws-auth -n kube-system
