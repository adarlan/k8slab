
resource "aws_eks_node_group" "private_node_group" {
  cluster_name = var.cluster_name

  node_group_name = "private-node-group"
  subnet_ids      = var.private_subnet_ids

  node_role_arn = aws_iam_role.node_group_role.arn

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 0
  }

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
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

  tags = merge(var.tags, { Name = "${var.cluster_name}/private-node-group" })
}
