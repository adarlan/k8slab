
resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = 3
    max_size     = 6
    min_size     = 2
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.node_group_role_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_role_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_role_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_group_route53_policy_attachment,
  ]
  labels = {
    role = "general"
  }
  tags = merge(var.tags, { Name = "${var.cluster_name}/node-group/default" })
}
