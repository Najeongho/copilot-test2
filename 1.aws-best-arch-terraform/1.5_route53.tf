resource "aws_route53_zone" "example" {
  name = "example.com"
}

resource "aws_route53_record" "example" {
  zone_id = aws_route53_zone.example.zone_id
  name    = "example.com"
  type    = "A"
  ttl     = "300"
  records = ["123.123.123.123"] # 이 IP 주소를 실제 EC2 인스턴스의 IP 주소로 변경해주세요.
}