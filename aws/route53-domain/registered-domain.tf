resource "aws_route53domains_registered_domain" "registered_domain" {

  # DOC https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53domains_registered_domain
  # NOTE This is an advanced resource and has special caveats to be aware of when using it

  # TODO Use this resource only if the domain is registered in AWS Route53

  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = aws_route53_delegation_set.delegation_set.name_servers
    content {
      name = name_server.value
    }
  }

  # NOTE You must specify the same privacy setting for admin_privacy, registrant_privacy and tech_privacy
  admin_privacy      = var.privacy
  registrant_privacy = var.privacy
  tech_privacy       = var.privacy
}
