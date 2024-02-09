
resource "kind_cluster" "default" {
    name       = var.cluster_name
    node_image = "kindest/node:v${var.kubernetes_version}"

    wait_for_ready = true

    kind_config {
        kind        = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"
        node {
            role = "control-plane"
            # extra_port_mappings {
            #     container_port = 30000
            #     host_port      = 30000
            #     # protocol       = "TCP"
            # }
        }
        node {
            role =  "worker"
        }
        node {
            role =  "worker"
        }
        node {
            role =  "worker"
        }
    }
}
