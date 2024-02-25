provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.3.0/24"
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.31.4.0/24"
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow inbound traffic from my IP only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your_ip/32"] # 여기에 실제 IP를 입력해주세요.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.31.3.0/24", "172.31.4.0/24"]
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-0a10b2721688ce9d2" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3a.medium"
  subnet_id     = aws_subnet.public1.id
  key_name      = "your_key_pair" # 여기에 실제 키 페어 이름을 입력해주세요.

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "Bastion Host"
  }
}