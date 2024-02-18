

resource "aws_iam_role" "karpenter_controller_role" {
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json
  name               = "${var.cluster_name}/karpenter-role"
  tags               = merge(var.tags, { Name = "${var.cluster_name}/karpenter-role" })
}

data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
    principals {
      identifiers = [var.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "karpenter_controller_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "iam:PassRole",
      "ec2:RunInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DeleteLaunchTemplate",
      "ec2:CreateTags",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
    ]
    resources = ["*"]
    sid       = "Karpenter"
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:TerminateInstances"]
    resources = ["*"]
    sid       = "ConditionalEC2Termination"
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"
      values   = ["*karpenter*"]
    }
  }
}

resource "aws_iam_policy" "karpenter_controller_policy" {
  policy = data.aws_iam_policy_document.karpenter_controller_policy_document.json
  name   = "${var.cluster_name}/karpenter-policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_role_policy_attachment" {
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}

# TODO cluster policies?
resource "aws_iam_role_policy_attachment" "karpenter_controller_role_policy_attachment_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.karpenter_controller_role.name
}
resource "aws_iam_role_policy_attachment" "karpenter_controller_role_policy_attachment_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.karpenter_controller_role.name
}

# TODO node policies?
resource "aws_iam_role_policy_attachment" "karpenter_controller_role_policy_attachment_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter_controller_role.name
}
resource "aws_iam_role_policy_attachment" "karpenter_controller_role_policy_attachment_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_controller_role.name
}
resource "aws_iam_role_policy_attachment" "karpenter_controller_role_policy_attachment_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter_controller_role.name
}
