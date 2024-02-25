data "aws_iam_policy_document" "eks_ebs_csi_driver_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_ebs_csi_driver_role" {
  name               = "ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.eks_ebs_csi_driver_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.eks_ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_EBS_CSI_Driver_Policy"
}

module "eks" {
  # ...

  map_roles = [
    # ...

    {
      rolearn  = aws_iam_role.eks_ebs_csi_driver_role.arn
      username = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      groups   = ["system:masters"]
    }
  ]
}

data "helm_repository" "aws" {
  name = "aws"
  url  = "https://aws.github.io/eks-charts"
}

resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = data.helm_repository.aws.metadata.0.name
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"

  set {
    name  = "serviceAccount.controller.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.controller.name"
    value = "ebs-csi-controller-sa"
  }
}