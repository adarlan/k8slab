resource "aws_route53_record" "root_record" {
  zone_id = aws_route53_zone.zone.id
  name    = ""
  type    = "A"
  ttl     = 300
  records = [var.target_address]
}

resource "aws_route53_record" "www_alias" {
  zone_id = aws_route53_zone.zone.id
  name    = "www"
  type    = "CNAME"
  ttl     = 60
  records = [var.domain_name]
}
