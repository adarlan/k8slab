locals {
  kubeconfig_path = pathexpand("./${var.cluster_name}.kubeconfig")
}
