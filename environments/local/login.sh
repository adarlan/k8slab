#!/bin/bash
set -e

printf "\nConfiguring kubectl\n"
cp ./kubeconfig ~/.kube/config
# TODO merge and use context instead of replacing

kubectl cluster-info

ARGOCD_HOST="localhost"
ARGOCD_PORT="8080"
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)

printf "\nLogging into Argo CD server\n"
argocd login --insecure $ARGOCD_HOST:$ARGOCD_PORT --username admin --password $ARGOCD_PASSWORD

printf "\nOpen Argo CD in your browser\n"
echo -e "- URL:      \033[33mhttps://$ARGOCD_HOST:$ARGOCD_PORT\033[0m"
echo -e "- Username: \033[33madmin\033[0m"
echo -e "- Password: \033[33m$ARGOCD_PASSWORD\033[0m"
