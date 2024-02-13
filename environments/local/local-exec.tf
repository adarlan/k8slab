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

  # TODO must wait for argo-cd is ready. depends_on is not enough

  depends_on = [
    module.kind_cluster,
    module.ingress_nginx,
    module.argo_cd,
  ]
}
