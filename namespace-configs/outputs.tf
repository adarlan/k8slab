output "argocd_application_deployer_token" {
  value     = data.kubernetes_secret.argocd_application_deployer.data["token"]
  sensitive = true
}
