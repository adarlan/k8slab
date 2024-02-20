module "ingress_nginx" {
  source     = "./../../cluster-tools/ingress-nginx"
  count      = var.ingress_nginx != null ? 1 : 0

  kind_config = {}
}
