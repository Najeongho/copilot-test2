provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = data.helm_repository.argo.metadata.0.name
  chart      = "argo-cd"
  namespace  = "argocd"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}