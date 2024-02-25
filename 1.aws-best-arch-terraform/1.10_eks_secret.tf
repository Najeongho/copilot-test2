module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-cluster"
  cluster_version = "1.20"
  subnets         = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  vpc_id          = "vpc-abcde012"

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "m5.large"
      key_name      = "my-key"
    }
  }
}

resource "aws_secretsmanager_secret" "example" {
  name        = "example_secret"
  description = "This is an example secret"
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.example.id
  secret_string = "supersecret"
}

resource "kubernetes_secret" "example" {
  metadata {
    name = "example"
  }

  data = {
    secret = aws_secretsmanager_secret.example.name
  }

  type = "Opaque"
}