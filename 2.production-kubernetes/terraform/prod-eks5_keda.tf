provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

data "helm_repository" "bitnami" {
  name = "bitnami"
  url  = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "keda" {
  name       = "keda"
  repository = data.helm_repository.bitnami.metadata.0.name
  chart      = "keda"
  namespace  = "keda"

  set {
    name  = "watchNamespace"
    value = ""
  }
}