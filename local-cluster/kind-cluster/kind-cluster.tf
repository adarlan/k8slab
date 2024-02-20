resource "kind_cluster" "default" {
  name       = var.cluster_name
  node_image = "kindest/node:v${var.kubernetes_version}"

  wait_for_ready = true

  kubeconfig_path = pathexpand("~/.kube/config")
  # TODO create variable and use this value as defaul
  # It won't replace the existing file, just will merge them

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        <<-EOF
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "${local.controll_plane_node_labels_string}"
        EOF
      ]

      dynamic "extra_port_mappings" {
        for_each = var.port_mappings
        content {
          container_port = tonumber(extra_port_mappings.value.node_port)
          host_port      = tonumber(extra_port_mappings.value.host_port)
        }
      }
    }

    dynamic "node" {
      for_each = range(var.worker_nodes)
      content {
        role = "worker"
      }
    }
  }
}
