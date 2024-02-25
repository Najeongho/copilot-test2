resource "aws_secretsmanager_secret" "example" {
  name        = "example_secret"
  description = "This is an example secret"
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.example.id
  secret_string = "supersecret"
}