resource "aws_elasticsearch_domain" "example" {
  domain_name           = "example"
  elasticsearch_version = "7.9"

  cluster_config {
    instance_type = "m5.large.elasticsearch"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 35
  }
}

resource "aws_elasticsearch_domain_policy" "example" {
  domain_name = aws_elasticsearch_domain.example.domain_name

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "${aws_elasticsearch_domain.example.arn}/*"
    }
  ]
}
POLICIES
}

output "dashboard_url" {
  value = aws_elasticsearch_domain.example.kibana_endpoint
}