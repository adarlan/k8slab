resource "aws_route53_record" "redord" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.subdomain
  type    = "A"
  ttl     = 300
  records = [
    var.target_address
  ]
}
