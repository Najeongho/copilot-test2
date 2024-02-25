data "aws_iam_policy_document" "eks_karpenter_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_karpenter_role" {
  name               = "karpenter"
  assume_role_policy = data.aws_iam_policy_document.eks_karpenter_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_karpenter_policy_attachment" {
  role       = aws_iam_role.eks_karpenter_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSKarpenterControllerPolicy"
}

module "eks" {
  # ...

  map_roles = [
    # ...

    {
      rolearn  = aws_iam_role.eks_karpenter_role.arn
      username = "system:serviceaccount:karpenter:karpenter"
      groups   = ["system:masters"]
    }
  ]
}

data "helm_repository" "karpenter" {
  name = "karpenter"
  url  = "https://charts.karpenter.sh"
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = data.helm_repository.karpenter.metadata.0.name
  chart      = "karpenter"
  namespace  = "karpenter"

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "karpenter"
  }

  set {
    name  = "clusterName"
    value = "my-eks-cluster"
  }

  set {
    name  = "region"
    value = "us-west-2"
  }
}