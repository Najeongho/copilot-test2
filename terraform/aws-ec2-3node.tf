# Define the provider
provider "aws" {
  region = "ap-northeast-2"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.31.0.0/16"

    // DNS 호스트 이름 - 활성화됨
  enable_dns_hostnames = "true"

  // DNS 확인 - 활성화됨
  enable_dns_support = "true"
}

# Create subnets
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "172.31.0.0/24"

    // 퍼블릭 IPv4 주소 자동 할당
  map_public_ip_on_launch = true

  tags = {

    // 서브넷 별 태그 번호 순차 변경
    Name = "test-public-subnet1"

    // 서브넷에 로드 밸런서 배포시 필요한 태그 - 퍼블릭 서브넷
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "172.31.1.0/24"

    // 퍼블릭 IPv4 주소 자동 할당
  map_public_ip_on_launch = true

  tags = {

    // 서브넷 별 태그 번호 순차 변경
    Name = "test-public-subnet2"

    // 서브넷에 로드 밸런서 배포시 필요한 태그 - 퍼블릭 서브넷
    "kubernetes.io/role/elb" = 1
  }
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate subnets with the route table
resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create security group
resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Allow SSH access from my IP"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<My IP>/32"]
  }
}

# Generate SSH key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create EC2 instances
resource "aws_instance" "ec2_instance" {
  count         = 3
  instance_type = "t3a.medium"
  ami           = "ami-04599ab1182cd7961"  # Amazon Linux 2 AMI ID

  subnet_id               = aws_subnet.subnet1.id  # Choose one of the subnets
  vpc_security_group_ids  = [aws_security_group.my_security_group.id]
  key_name                = aws_key_pair.my_key_pair.key_name

  // 퍼블릭 IP 자동 할당
  associate_public_ip_address = "true"

  # Add EBS volume configuration
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "EC2 Instance ${count.index + 1}"
  }
}

