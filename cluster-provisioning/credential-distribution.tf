resource "local_file" "endpoint" {
  filename = "../cluster-endpoint.txt"
  content  = kind_cluster.k8slab.endpoint
}

resource "local_file" "ca_key" {
  filename = "../cluster-ca.key"
  content  = data.local_file.ca_key.content
}

resource "local_file" "ca_certificate" {
  filename = "../cluster-ca.crt"
  content  = kind_cluster.k8slab.cluster_ca_certificate
}

resource "local_file" "root_user_key" {
  filename = "../root.key"
  content  = kind_cluster.k8slab.client_key
}

resource "local_file" "root_user_certificate" {
  filename = "../root.crt"
  content  = kind_cluster.k8slab.client_certificate
}
