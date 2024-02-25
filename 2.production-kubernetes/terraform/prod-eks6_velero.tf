data "aws_iam_policy_document" "eks_velero_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_velero_role" {
  name               = "velero"
  assume_role_policy = data.aws_iam_policy_document.eks_velero_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_velero_policy_attachment" {
  role       = aws_iam_role.eks_velero_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_s3_bucket" "velero" {
  bucket = "my-velero-bucket"
  acl    = "private"
}

module "eks" {
  # ...

  map_roles = [
    # ...

    {
      rolearn  = aws_iam_role.eks_velero_role.arn
      username = "system:serviceaccount:velero:velero"
      groups   = ["system:masters"]
    }
  ]
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

data "helm_repository" "vmware-tanzu" {
  name = "vmware-tanzu"
  url  = "https://vmware-tanzu.github.io/helm-charts"
}

resource "helm_release" "velero" {
  name       = "velero"
  repository = data.helm_repository.vmware-tanzu.metadata.0.name
  chart      = "velero"
  namespace  = "velero"

  set {
    name  = "configuration.provider"
    value = "aws"
  }

  set {
    name  = "configuration.backupStorageLocation.name"
    value = "aws"
  }

  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = aws_s3_bucket.velero.id
  }

  set {
    name  = "configuration.backupStorageLocation.config.region"
    value = "us-west-2"
  }

  set {
    name  = "credentials.secretContents.cloud"
    value = "AWS_ACCESS_KEY_ID=${aws_access_key.velero.id}\nAWS_SECRET_ACCESS_KEY=${aws_access_key.velero.secret}"
  }

  set {
    name  = "snapshotsEnabled"
    value = "true"
  }
}