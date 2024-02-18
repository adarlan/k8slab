resource "aws_route53_zone" "main" {
  name              = var.domain
  delegation_set_id = aws_route53_delegation_set.main.id
}

resource "aws_route53_delegation_set" "main" {
  reference_name = var.domain
}
