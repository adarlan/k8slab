resource "null_resource" "local_exec" {

  depends_on = [kind_cluster.k8slab]

  provisioner "local-exec" {
    interpreter = ["sh", "-c"]
    command     = "docker cp k8slab-control-plane:/etc/kubernetes/pki/ca.key ca.key"
  }
}

data "local_file" "ca_key" {

  depends_on = [null_resource.local_exec]

  filename = "${path.module}/ca.key"
}
