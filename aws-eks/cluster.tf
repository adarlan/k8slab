
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.27"
  vpc_config {
    security_group_ids      = [aws_security_group.cluster_security_group.id]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }
  tags = merge(var.tags, { Name = var.cluster_name })
}
