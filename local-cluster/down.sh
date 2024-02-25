#!/bin/bash
source handy-functions.sh

undeploy-app hello-world

terraform-config

terraform-destroy argo-cd               || force-destroy argo-cd               || true
terraform-destroy kube-prometheus-stack || force-destroy kube-prometheus-stack || true
terraform-destroy ingress-nginx         || force-destroy ingress-nginx         || true
terraform-destroy trivy-operator        || force-destroy trivy-operator        || true

terraform-destroy kind-cluster          || force-destroy kind-cluster

git-clean argo-cd
git-clean kube-prometheus-stack
git-clean ingress-nginx
git-clean trivy-operator
git-clean kind-cluster
