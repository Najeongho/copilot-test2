provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
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