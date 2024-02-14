#!/bin/bash
set -e

display() {
    printf "\n\033[1m$1\033[0m\n"
    echo -e "\033[34m$2\033[0m"
    [ -n "$3" ] && echo -e "Username \033[33m$3\033[0m" || true
    [ -n "$4" ] && echo -e "Password \033[33m$4\033[0m" || true
}

ARGOCD_PORT=$(terraform output -raw argocd_port)
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)

PROMETHEUS_PORT=$(terraform output -raw prometheus_port)

GRAFANA_PORT=$(terraform output -raw grafana_port)
GRAFANA_USERNAME=$(kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-user}" | base64 --decode)
GRAFANA_PASSWORD=$(kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)

display "Argo CD"    https://localhost:$ARGOCD_PORT admin $ARGOCD_PASSWORD
display "Prometheus" http://localhost:$PROMETHEUS_PORT
display "Grafana"    http://localhost:$GRAFANA_PORT $GRAFANA_USERNAME $GRAFANA_PASSWORD

echo
