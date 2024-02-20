resource "aws_route53domains_registered_domain" "registered_domain" {

  # DOC https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53domains_registered_domain

  # NOTE This resource behaves differently from normal resources
  # Terraform does not register the domain, but instead "adopts" it into management
  # Terraform won't create or delete the domain registration
  # This resource is used only to set attributes in the registered domain

  count = local.is_domain_registered_in_route53 ? 1 : 0

  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = aws_route53_delegation_set.delegation_set.name_servers
    content {
      name = name_server.value
    }
  }

  # NOTE You must specify the same privacy setting for admin_privacy, registrant_privacy and tech_privacy
  admin_privacy      = var.registered_domain.set_privacy
  registrant_privacy = var.registered_domain.set_privacy
  tech_privacy       = var.registered_domain.set_privacy

  # TODO Add more properties
}
