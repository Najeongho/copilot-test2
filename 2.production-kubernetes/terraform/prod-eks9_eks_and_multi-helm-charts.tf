provider "aws" {
  region = "us-west-2"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.20"
  subnets         = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  vpc_id          = "vpc-abcde012"

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "m5.large"
      key_name      = "my-key-name"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.host
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = module.eks.cluster_iam_role_arn
    load_config_file       = false
  }
}

variable "helm_charts" {
  description = "List of Helm charts to install"
  type        = list(object({
    name       = string
    repository = string
    chart      = string
    namespace  = string
  }))

  default = [
    {
      name       = "argocd"
      repository = "https://argoproj.github.io/argo-helm"
      chart      = "argo-cd"
      namespace  = "argocd"
    },
    {
      name       = "keda"
      repository = "https://charts.bitnami.com/bitnami"
      chart      = "keda"
      namespace  = "keda"
    }
    # Add more charts as needed
  ]
}

data "helm_repository" "repo" {
  count = length(var.helm_charts)
  name  = "repo${count.index}"
  url   = var.helm_charts[count.index].repository
}

resource "helm_release" "chart" {
  count      = length(var.helm_charts)
  name       = var.helm_charts[count.index].name
  repository = data.helm_repository.repo[count.index].metadata[0].name
  chart      = var.helm_charts[count.index].chart
  namespace  = var.helm_charts[count.index].namespace
}