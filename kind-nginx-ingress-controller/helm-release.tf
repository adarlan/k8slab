
resource "helm_release" "kind_nginx_ingress_controller" {
  name  = "kind-nginx-ingress-controller"
  
  chart = "./../kind-nginx-ingress-controller/helm-chart"
  # TODO the path is relative from where you run terraform, not from this .tf file
}
