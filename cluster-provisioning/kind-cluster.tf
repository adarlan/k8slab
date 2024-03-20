resource "kind_cluster" "k8slab" {

  name = "k8slab"

  node_image     = "kindest/node:v1.29.1"
  wait_for_ready = true

  kubeconfig_path = "kind.kubeconfig"

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
            node-labels: "${var.control_plane_node_labels}"
        EOF
      ]

      dynamic "extra_port_mappings" {
        for_each = var.control_plane_port_mappings
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
