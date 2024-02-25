data "aws_iam_policy_document" "eks_lb_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_lb_controller_role" {
  name               = "aws-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.eks_lb_controller_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_lb_controller_policy_attachment" {
  role       = aws_iam_role.eks_lb_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}

module "eks" {
  # ...

  map_roles = [
    {
      rolearn  = aws_iam_role.eks_lb_controller_role.arn
      username = "system:serviceaccount:kube-system:aws-load-balancer-controller"
      groups   = ["system:masters"]
    }
  ]
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

data "helm_repository" "bitnami" {
  name = "bitnami"
  url  = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = data.helm_repository.bitnami.metadata.0.name
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = "my-eks-cluster"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = "us-west-2"
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
}