resource "aws_route53_zone" "zone" {

  # DOC https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone

  name = var.domain_name

  delegation_set_id = aws_route53_delegation_set.delegation_set.id
}
