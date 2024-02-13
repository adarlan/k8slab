data "aws_eks_addon_version" "ebs_csi_driver_version" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi_driver" {
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi_driver_version.version
  cluster_name  = var.cluster_name
  tags          = merge(var.tags, { Name = "${var.cluster_name}/ebs-csi-driver" })
}

data "aws_eks_node_groups" "eks_node_groups" {
  cluster_name = var.cluster_name
}

data "aws_eks_node_group" "eks_node_group" {
  for_each        = data.aws_eks_node_groups.eks_node_groups.names
  cluster_name    = var.cluster_name
  node_group_name = each.value
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {

  for_each = toset([
    for parts in [for arn in data.aws_eks_node_group.eks_node_group : split("/", arn.node_role_arn)] :
    parts[1]
    ]
  )

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = each.value
}
