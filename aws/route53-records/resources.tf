data "aws_route53_zone" "main" {
  name         = "${var.domain}."
}

resource "aws_route53_record" "A_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = ""
  type    = "A"
  ttl     = "300"
  records = [var.public_ip]
}

resource "aws_route53_record" "CNAME_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "300"
  records = [var.domain]
}

# --------------

resource "aws_route53_record" "route_53_record_teleport" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "foo" # subdomain
  type    = "A"
  ttl     = 300
  records = [
    # TODO IP adresses
  ]
}

resource "aws_route53_record" "route_53_record_teleport_wildcard" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "*.foo" # wildcard for any sub-subdomain
  type    = "A"
  ttl     = 300
  records = [
    # TODO IP adresses
  ]
}
