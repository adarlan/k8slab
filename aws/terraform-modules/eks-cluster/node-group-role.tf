
resource "aws_iam_role" "node_group_role" {
  name = "${var.cluster_name}/node-group-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = merge(var.tags, { Name = "${var.cluster_name}/node-group-role" })
}

resource "aws_iam_role_policy_attachment" "node_group_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node_group_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node_group_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

# TODO what is it used for?
resource "aws_iam_role_policy_attachment" "node_group_route53_policy_attachment" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = aws_iam_policy.node_group_route53_policy.arn
}
resource "aws_iam_policy" "node_group_route53_policy" {
  policy = data.aws_iam_policy_document.node_group_route53_policy_document.json
  name   = "${var.cluster_name}/node-group-route53-policy"
}
data "aws_iam_policy_document" "node_group_route53_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
}
