output "name_servers" {
  value = join(";", aws_route53_delegation_set.main.name_servers)
}
