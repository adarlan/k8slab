
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
  tags         = merge(var.tags, { Name = "${var.cluster_name}/vpc-cni" })
}

resource "aws_eks_addon" "core_dns" {
  cluster_name = var.cluster_name
  addon_name   = "coredns"
  tags         = merge(var.tags, { Name = "${var.cluster_name}/core-dns" })
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = var.cluster_name
  addon_name   = "kube-proxy"
  tags         = merge(var.tags, { Name = "${var.cluster_name}/kube-proxy" })
}
