
resource "aws_eks_cluster" "cluster" {
  name    = var.cluster_name
  version = "1.27"

  role_arn   = aws_iam_role.cluster_role.arn
  depends_on = [aws_iam_role_policy_attachment.cluster_role_AmazonEKSClusterPolicy]

  vpc_config {
    endpoint_private_access = var.is_production
    endpoint_public_access  = !var.is_production
    public_access_cidrs     = ["0.0.0.0/0"]

    subnet_ids = var.subnet_ids

    security_group_ids = [aws_security_group.cluster_security_group.id]
  }

  tags = merge(var.tags, { Name = var.cluster_name })
}
