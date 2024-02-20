module "trivy_operator" {
  source     = "./../../cluster-tools/trivy-operator"
  count      = var.trivy_operator != null ? 1 : 0
}
