resource "local_file" "argocd_application_deployer_token" {
  filename = "../argocd-application-deployer.token"
  content  = data.kubernetes_secret.argocd_application_deployer.data["token"]
}
