worker_node_count         = 2
control_plane_node_labels = "ingress-ready=true"

control_plane_port_mappings = [
  { host_port = 80, node_port = 80 },
  { host_port = 443, node_port = 443 },
]
