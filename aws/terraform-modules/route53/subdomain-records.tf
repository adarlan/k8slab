resource "aws_route53_record" "redord" {
  count = length(var.subdomains)

  zone_id = aws_route53_zone.zone.id
  name    = var.subdomains[count.index].subdomain_name

  type    = "A" # TODO could also be CNAME? note: if CNAME, ttl=60
  ttl     = 300

  records = [
    var.subdomains[count.index].target_address
  ]
}
