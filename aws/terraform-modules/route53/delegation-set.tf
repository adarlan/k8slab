resource "aws_route53_delegation_set" "delegation_set" {

  # DOC https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_delegation_set

  reference_name = var.domain_name
}
