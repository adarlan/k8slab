
resource "null_resource" "local_exec" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF

      echo "Copying kubeconfig file to ~/.kube/config"
      cp ${pathexpand("./kubeconfig")} ${pathexpand("~/.kube/config")}
      # TODO merge and use context instead of replacing

      echo "Interacting with the cluster"
      kubectl cluster-info

    EOF
  }

  depends_on = [
    module.kind-cluster,
    module.kind-nginx-ingress-controller,
    module.argo-cd,
  ]
}
