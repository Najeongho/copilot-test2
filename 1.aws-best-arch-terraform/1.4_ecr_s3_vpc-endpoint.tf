resource "aws_ecr_repository" "test" {
  name = "test"
}

resource "aws_s3_bucket" "test" {
  bucket = "test"
  acl    = "private"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-northeast-2.s3"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.ecr_access.id]
  subnet_ids         = [aws_subnet.private1.id, aws_subnet.private2.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-2.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.ecr_access.id]
  subnet_ids         = [aws_subnet.private1.id, aws_subnet.private2.id]

  private_dns_enabled = true
}

resource "aws_security_group" "ecr_access" {
  name        = "ecr_access"
  description = "Allow inbound traffic to ECR"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}