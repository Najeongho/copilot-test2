resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c574c8"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo docker run -d -p 9090:9090 prom/prometheus
              sudo docker run -d -p 3000:3000 grafana/grafana
              EOF

  tags = {
    Name = "example-instance"
  }
}

output "prometheus_url" {
  value = "http://${aws_instance.example.public_ip}:9090"
}

output "grafana_url" {
  value = "http://${aws_instance.example.public_ip}:3000"
}