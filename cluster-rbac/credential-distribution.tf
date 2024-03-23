resource "local_file" "namespace_provisioning_token" {
  filename = "../namespace-provisioning.token"
  content  = data.kubernetes_secret.namespace_provisioning.data["token"]
}

resource "local_file" "namespace_rbac_token" {
  filename = "../namespace-rbac.token"
  content  = data.kubernetes_secret.namespace_rbac.data["token"]
}

resource "local_file" "cluster_toolkit_token" {
  filename = "../cluster-toolkit.token"
  content  = data.kubernetes_secret.cluster_toolkit.data["token"]
}
