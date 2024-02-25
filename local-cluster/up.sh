#!/bin/bash
source handy-functions.sh

terraform-config

terraform-apply kind-cluster

terraform-apply trivy-operator
terraform-apply ingress-nginx
terraform-apply kube-prometheus-stack
terraform-apply argo-cd

kubectl-config
helm-config
argocd-config

deploy-app hello-world

info
