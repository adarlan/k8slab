locals {
  is_domain_registered_in_route53 = can(var.registered_domain)
}
