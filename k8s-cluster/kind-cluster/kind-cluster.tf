
resource "kind_cluster" "default" {
  name       = var.cluster_name
  node_image = "kindest/node:v${var.kubernetes_version}"

  wait_for_ready = true

  kubeconfig_path = pathexpand("./kubeconfig")
  # This file will be created in the directory where 'terraform apply' is executed, not within this module's directory

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      # ingress-nginx
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }

      # argocd-server
      extra_port_mappings {
        container_port = 30080
        host_port      = 8080
      }
      extra_port_mappings {
        container_port = 30443
        host_port      = 8443
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
