worker_node_count         = 2
control_plane_node_labels = "ingress-ready=true"

control_plane_port_mappings = [
  { host_port = 80, node_port = 80 },
  { host_port = 443, node_port = 443 },
  { host_port = 8001, node_port = 30001 },
  { host_port = 8002, node_port = 30002 },
  { host_port = 8003, node_port = 30003 },
  { host_port = 8004, node_port = 30004 },
]
