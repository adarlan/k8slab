resource "kind_cluster" "default" {

  name = "k8slab"

  node_image     = "kindest/node:v1.29.1"
  wait_for_ready = true

  kubeconfig_path = pathexpand("~/.kube/config")
  # TODO create variable and use this value as defaul
  # It won't replace the existing file, just will merge them

  kind_config {

    api_version = "kind.x-k8s.io/v1alpha4"
    kind        = "Cluster"

    node {
      role = "control-plane"

      # TODO what if it has multi control-plane? how to configure labels and ports? specially for ingress

      kubeadm_config_patches = [
        <<-EOF
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "${var.controll_plane_node_labels}"
        EOF
      ]

      dynamic "extra_port_mappings" {
        for_each = var.port_mappings
        content {
          container_port = extra_port_mappings.value.node_port
          host_port      = extra_port_mappings.value.host_port
        }
      }
    }

    dynamic "node" {
      for_each = range(var.worker_node_count)
      content {
        role = "worker"
      }
    }
  }
}
