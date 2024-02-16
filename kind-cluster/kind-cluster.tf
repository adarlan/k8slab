resource "kind_cluster" "default" {
  name       = var.cluster_name
  node_image = "kindest/node:v${var.kubernetes_version}"

  wait_for_ready = true

  kubeconfig_path = local.kubeconfig_path

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      # ingress
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }

      dynamic "extra_port_mappings" {
        for_each = var.node_to_host_port_mapping
        content {
          container_port = tonumber(extra_port_mappings.key)
          host_port      = tonumber(extra_port_mappings.value)
        }
      }
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
}
