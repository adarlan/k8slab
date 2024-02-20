locals {
  port_mappings_by_name = {
    for port_mapping in var.port_mappings : port_mapping.name => {
      host_port = port_mapping.host_port
      node_port = port_mapping.node_port
    }
  }
}
